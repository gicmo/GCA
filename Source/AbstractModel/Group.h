//
//  Group.h
//  GCA
//
//  Created by Christian Kellner on 10/08/15.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Conference;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t prefix;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) Conference *conference;
@property (nonatomic, retain) NSOrderedSet *abstracts;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)insertObject:(Abstract *)value inAbstractsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAbstractsAtIndex:(NSUInteger)idx;
- (void)insertAbstracts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAbstractsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAbstractsAtIndex:(NSUInteger)idx withObject:(Abstract *)value;
- (void)replaceAbstractsAtIndexes:(NSIndexSet *)indexes withAbstracts:(NSArray *)values;
- (void)addAbstractsObject:(Abstract *)value;
- (void)removeAbstractsObject:(Abstract *)value;
- (void)addAbstracts:(NSOrderedSet *)values;
- (void)removeAbstracts:(NSOrderedSet *)values;
@end
