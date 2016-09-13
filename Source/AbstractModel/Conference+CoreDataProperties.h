//Copyright (c) 2012-2016, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2016, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import "Conference.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conference (CoreDataProperties)

@property (nonatomic) NSTimeInterval deadline;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nonatomic) NSTimeInterval end;
@property (nullable, nonatomic, retain) NSString *link;
@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic) NSTimeInterval start;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *etag;
@property (nullable, nonatomic, retain) NSString *etagAbstracts;
@property (nullable, nonatomic, retain) NSString *map;
@property (nullable, nonatomic, retain) NSString *info;
@property (nullable, nonatomic, retain) NSString *schedule;
@property (nullable, nonatomic, retain) NSSet<Abstract *> *abstracts;
@property (nullable, nonatomic, retain) NSOrderedSet<Group *> *groups;

@end

@interface Conference (CoreDataGeneratedAccessors)

- (void)addAbstractsObject:(Abstract *)value;
- (void)removeAbstractsObject:(Abstract *)value;
- (void)addAbstracts:(NSSet<Abstract *> *)values;
- (void)removeAbstracts:(NSSet<Abstract *> *)values;

- (void)insertObject:(Group *)value inGroupsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromGroupsAtIndex:(NSUInteger)idx;
- (void)insertGroups:(NSArray<Group *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeGroupsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInGroupsAtIndex:(NSUInteger)idx withObject:(Group *)value;
- (void)replaceGroupsAtIndexes:(NSIndexSet *)indexes withGroups:(NSArray<Group *> *)values;
- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSOrderedSet<Group *> *)values;
- (void)removeGroups:(NSOrderedSet<Group *> *)values;

@end

NS_ASSUME_NONNULL_END
