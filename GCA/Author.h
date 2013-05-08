//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Affiliation, Correspondence;

@interface Author : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *isAffiliatedTo;
@property (nonatomic, retain) NSSet *isCorresponding;
@property (nonatomic, retain) NSSet *wroteAbstract;
@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addIsAffiliatedToObject:(Affiliation *)value;
- (void)removeIsAffiliatedToObject:(Affiliation *)value;
- (void)addIsAffiliatedTo:(NSSet *)values;
- (void)removeIsAffiliatedTo:(NSSet *)values;

- (void)addIsCorrespondingObject:(Correspondence *)value;
- (void)removeIsCorrespondingObject:(Correspondence *)value;
- (void)addIsCorresponding:(NSSet *)values;
- (void)removeIsCorresponding:(NSSet *)values;

- (void)addWroteAbstractObject:(Abstract *)value;
- (void)removeWroteAbstractObject:(Abstract *)value;
- (void)addWroteAbstract:(NSSet *)values;
- (void)removeWroteAbstract:(NSSet *)values;

@end
