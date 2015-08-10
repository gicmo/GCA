//
//  Group.h
//  GCA
//
//  Created by Christian Kellner on 10/08/15.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conference;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t prefix;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * brief;
@property (nonatomic, retain) Conference *conference;

@end
