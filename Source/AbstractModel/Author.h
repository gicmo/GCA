//
//  Author.h
//  GCA
//
//  Created by Christian Kellner on 19/08/14.
//  Copyright (c) 2014 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Affiliation, Correspondence;

@interface Author : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * uuid;
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
