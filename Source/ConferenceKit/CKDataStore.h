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

+ (CKDataStore *) defaultStore;

@end
