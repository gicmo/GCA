//
//  CKDataStore.m
//
//  Created by Christian Kellner on 17/08/2013.
//  Copyright (c) 2013-2022 G-Node. All rights reserved.
//

#import "CKDataStore.h"



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
            
            NSPersistentStoreDescription *desc = __container.persistentStoreDescriptions.firstObject;
            
            if (desc != nil) {
                NSNumber *trueNum = [NSNumber numberWithBool:YES];
                [desc setOption:trueNum forKey:NSPersistentHistoryTrackingKey];
                [desc setOption:trueNum forKey:NSPersistentStoreRemoteChangeNotificationPostOptionKey];
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
    }
    
    return __container;
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
