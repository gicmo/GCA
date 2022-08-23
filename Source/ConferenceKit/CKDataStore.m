//
//  CKDataStore.m
//
//  Created by Christian Kellner on 17/08/2013.
//  Copyright (c) 2013-2022 G-Node. All rights reserved.
//

#import "CKDataStore.h"

#import "Conference.h"

@interface CKDataStore()
@property (strong) NSString *remoteChangeToken;
- (void)remoteStoreChanged:(NSNotification *)notification;
@end

@implementation CKDataStore

@synthesize managedObjectContext = __managedObjectContext;
@synthesize container = __container;
@synthesize lastToken = __lastToken;
@synthesize tokenURL = __tokenURL;

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    return self.container.viewContext;
}

-(NSPersistentContainer *) container {

    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (__container == nil) {
            __container = [[NSPersistentContainer alloc] initWithName:@"Abstracts"];
           
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(remoteStoreChanged:) name:NSPersistentStoreRemoteChangeNotification object:nil];
            
            NSPersistentStoreDescription *desc = __container.persistentStoreDescriptions.firstObject;
            
            if (desc != nil) {
                NSNumber *trueNum = [NSNumber numberWithBool:YES];
                [desc setOption:trueNum forKey:NSPersistentHistoryTrackingKey];
                [desc setOption:trueNum forKey:NSPersistentStoreRemoteChangeNotificationPostOptionKey];
            }
            
            // for debugging and developing
            if (YES) {
                desc.URL = [NSURL fileURLWithPath:@"/dev/null"];
                self.lastToken = nil;
            }
            
            [__container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // TODO
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
        
        __container.viewContext.name = @"viewContext";
        __container.viewContext.undoManager = nil;
        __container.viewContext.shouldDeleteInaccessibleFaults = YES;
        //__container.viewContext.automaticallyMergesChangesFromParent = YES;
    }
    
    return __container;
}

- (void)remoteStoreChanged:(NSNotification *)notification {
    NSLog(@"Got remote store changed notification");
    
    NSManagedObjectContext *ctx = [self.container newBackgroundContext];
    
    ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    ctx.undoManager = nil;
    
    [ctx performBlock:^{
        NSPersistentHistoryToken *token = self.lastToken;
        NSLog(@"last token: %@", token);
        NSPersistentHistoryChangeRequest *req = [NSPersistentHistoryChangeRequest fetchHistoryAfterToken:token];
        
        NSError *error = nil;
        NSPersistentHistoryResult *res = [ctx executeRequest:req error:&error];
        
        if (res == nil) {
            NSLog(@"WARN: could not fetch history: %@", error);
            return;
        }
        
        NSArray *history = (NSArray *) res.result;
        NSLog(@"history count: %ld", history.count);
        if (history.count > 0) {
           
            [self.container.viewContext performBlock:^{
                for (NSPersistentHistoryTransaction *tx in history) {
                    NSLog(@"TX: %@", tx);
                    [self.container.viewContext mergeChangesFromContextDidSaveNotification:tx.objectIDNotification];
                    self.lastToken = tx.token;
                }
                [self.container.viewContext save:nil];
            }];
            
        }
        
    }];
}

-(NSPersistentHistoryToken *) lastToken {
    if (__lastToken != nil) {
        return __lastToken;
    }
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:self.tokenURL];
    if (data == nil) {
        return nil;
    }
    
    NSError *error = nil;
    __lastToken = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSPersistentHistoryToken class] fromData:data error:&error];
    
    if (__lastToken == nil) {
        NSLog(@"failed to decode history token: %@", error);
    }
    
    return __lastToken;
}

-(void) setLastToken:(NSPersistentHistoryToken *)lastToken {
    
    if (lastToken == nil) {
        __lastToken = nil;
        [[NSFileManager defaultManager] removeItemAtURL:self.tokenURL error:nil];
        return;
    }
    
    NSError *error = nil;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:lastToken requiringSecureCoding:YES error:&error];
    
    if (data == nil) {
        NSLog(@"failed to encode history token: %@", error);
        return;
    }
    
    BOOL res = [data writeToURL:self.tokenURL atomically:YES];
    if (!res) {
        NSLog(@"failed to write history token");
        return;
    }
}

-(NSURL *) tokenURL {
    
    if (__tokenURL != nil) {
        return __tokenURL;
    }
    
    NSURL *dir = [[NSPersistentContainer defaultDirectoryURL] URLByAppendingPathComponent:@"GCA-iOS" isDirectory:TRUE];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir.path]) {
        NSError *error = nil;
        
        BOOL ok = [[NSFileManager defaultManager] createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!ok) {
            NSLog(@"Could not create directory at %@", dir);
            abort();
        }
    }
    
    __tokenURL = [dir URLByAppendingPathComponent:@"history.token" isDirectory:NO];
    return __tokenURL;
}

-(void) decodeConferences:(NSData *)data {
    NSManagedObjectContext *ctx = [self.container newBackgroundContext];
    
    ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    ctx.undoManager = nil;
    
    [ctx performBlock:^{
        id lst = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (![lst isKindOfClass:[NSArray class]]) {
            NSLog(@"NOT A Array!\n");
            return;
        }
        
        NSArray *confData = (NSArray *) lst;
        NSMutableDictionary *confByUUID = [NSMutableDictionary dictionary];
        NSMutableSet *server = [NSMutableSet setWithCapacity:confData.count];
        
        for (NSDictionary *d in lst) {
            NSLog(@"server: %@", d);
            [server addObject:d[@"uuid"]];
            confByUUID[d[@"uuid"]] = d;
        }
        
        NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Conference"];
        req.propertiesToFetch = @[@"uuid"];
        req.resultType = NSDictionaryResultType;
       
        NSError *error = nil;
        NSArray *res = [ctx executeFetchRequest:req error:&error];
        
        NSMutableSet *local = [NSMutableSet setWithCapacity:res.count];
        for (NSDictionary *d in res) {
            NSLog(@"have: %@", d);
            [server addObject:d[@"uuid"]];
        }
       
        NSMutableSet *created = [NSMutableSet setWithCapacity:server.count];
        [created setSet:server];
        [created minusSet:local];
        
        for (NSString *uuid in created) {
            NSLog(@"created: %@", uuid);
            NSDictionary *detail = confByUUID[uuid];
            
            Conference *conf = [NSEntityDescription insertNewObjectForEntityForName:@"Conference"
                                                             inManagedObjectContext:ctx];
            conf.uuid = uuid;
            conf.name = detail[@"name"];
        }
        
        BOOL ok = [ctx save:&error];
        if (!ok) {
            NSLog(@"failed to save context: %@", error);
        }
    }];
}

-(void) fetchConferences {
    NSURL *url = [NSURL URLWithString:@"https://abstracts.g-node.org/api/conferences"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse *) response;
        NSLog(@"status code: %ld", res.statusCode);
        if (res.statusCode == 200) {
            [self decodeConferences:data];
        }
    }];
    
    [task resume];
}


-(instancetype)init
{
    self = [super init];
    return self;
}

+(CKDataStore *)defaultStore
{
    static dispatch_once_t beacon;
    static CKDataStore *store = nil;
    
    dispatch_once(&beacon, ^() {
        store = [[CKDataStore alloc] init];
    });
    
    return store;
}

@end
