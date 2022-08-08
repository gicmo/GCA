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
            [__container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // TODO
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return __container;
    
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
