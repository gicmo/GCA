//
//  CKDataStore.h
//  NI2013
//
//  Created by Christian Kellner on 17/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

#import "CKSchedule.h"

@interface CKDataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong) NSPersistentContainer *container;
@property (readonly, strong) NSPersistentHistoryToken *lastToken;
@property (readonly, strong) NSURL *tokenURL;

+ (CKDataStore *) defaultStore;

@end
