//
//  Author.h
//  AbstractManager
//
//  Created by Christian Kellner on 8/9/12.
//  Copyright (c) 2012 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Affiliation, Correspondence;

@interface Author : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *isAffiliatedTo;
@property (nonatomic, retain) NSSet *wroteAbstract;
@property (nonatomic, retain) NSSet *isCorresponding;
@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addIsAffiliatedToObject:(Affiliation *)value;
- (void)removeIsAffiliatedToObject:(Affiliation *)value;
- (void)addIsAffiliatedTo:(NSSet *)values;
- (void)removeIsAffiliatedTo:(NSSet *)values;

- (void)addWroteAbstractObject:(Abstract *)value;
- (void)removeWroteAbstractObject:(Abstract *)value;
- (void)addWroteAbstract:(NSSet *)values;
- (void)removeWroteAbstract:(NSSet *)values;

- (void)addIsCorrespondingObject:(Correspondence *)value;
- (void)removeIsCorrespondingObject:(Correspondence *)value;
- (void)addIsCorresponding:(NSSet *)values;
- (void)removeIsCorresponding:(NSSet *)values;

@end
