//
//  Organization.h
//  AbstractManager
//
//  Created by Christian Kellner on 8/9/12.
//  Copyright (c) 2012 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Affiliation;

@interface Organization : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * department;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSSet *members;
@end

@interface Organization (CoreDataGeneratedAccessors)

- (void)addMembersObject:(Affiliation *)value;
- (void)removeMembersObject:(Affiliation *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end
