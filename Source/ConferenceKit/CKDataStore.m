//
//  CKDataStore.m
//
//  Created by Christian Kellner on 17/08/2013.
//  Copyright (c) 2013-2022 G-Node. All rights reserved.
//

#import "CKDataStore.h"



@implementation CKDataStore


@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Abstracts" withExtension:@"momd"];
    //NSLog(@"modelURL exits?: %d\n", [[NSFileManager defaultManager] fileExistsAtPath:[modelURL path]]);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    assert(urls && [urls count] > 0);
    
    NSURL *url = [urls[0] URLByAppendingPathComponent:@"Abstracts.storedata"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSDictionary *ps_opts = @{
                              NSSQLitePragmasOption: @{@"journal_mode":@"DELETE"},
                            };
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:url
                                                          options:ps_opts
                                                            error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
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
