//
//  Conference.h
//  GCA
//
//  Created by Christian Kellner on 10/08/15.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Group;

@interface Conference : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic) NSTimeInterval start;
@property (nonatomic) NSTimeInterval end;
@property (nonatomic) NSTimeInterval deadline;
@property (nonatomic, retain) NSSet *abstracts;
@property (nonatomic, retain) NSOrderedSet *groups;
@end

@interface Conference (CoreDataGeneratedAccessors)

- (void)addAbstractsObject:(Abstract *)value;
- (void)removeAbstractsObject:(Abstract *)value;
- (void)addAbstracts:(NSSet *)values;
- (void)removeAbstracts:(NSSet *)values;

- (void)insertObject:(Group *)value inGroupsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromGroupsAtIndex:(NSUInteger)idx;
- (void)insertGroups:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeGroupsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInGroupsAtIndex:(NSUInteger)idx withObject:(Group *)value;
- (void)replaceGroupsAtIndexes:(NSIndexSet *)indexes withGroups:(NSArray *)values;
- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSOrderedSet *)values;
- (void)removeGroups:(NSOrderedSet *)values;
@end
