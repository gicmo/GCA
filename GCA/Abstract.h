//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Affiliation, Author, Correspondence;

@interface Abstract : NSManagedObject

@property (nonatomic, retain) NSString * acknoledgements;
@property (nonatomic) int32_t aid;
@property (nonatomic, retain) NSString * conflictOfInterests;
@property (nonatomic, retain) NSString * frontid;
@property (nonatomic, retain) NSString * frontsubid;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) int32_t nfigures;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * references;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) NSString * session;
@property (nonatomic, retain) NSOrderedSet *affiliations;
@property (nonatomic, retain) NSOrderedSet *authors;
@property (nonatomic, retain) NSSet *correspondenceAt;
@end

@interface Abstract (CoreDataGeneratedAccessors)

- (void)insertObject:(Affiliation *)value inAffiliationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAffiliationsAtIndex:(NSUInteger)idx;
- (void)insertAffiliations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAffiliationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAffiliationsAtIndex:(NSUInteger)idx withObject:(Affiliation *)value;
- (void)replaceAffiliationsAtIndexes:(NSIndexSet *)indexes withAffiliations:(NSArray *)values;
- (void)addAffiliationsObject:(Affiliation *)value;
- (void)removeAffiliationsObject:(Affiliation *)value;
- (void)addAffiliations:(NSOrderedSet *)values;
- (void)removeAffiliations:(NSOrderedSet *)values;
- (void)insertObject:(Author *)value inAuthorsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAuthorsAtIndex:(NSUInteger)idx;
- (void)insertAuthors:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAuthorsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAuthorsAtIndex:(NSUInteger)idx withObject:(Author *)value;
- (void)replaceAuthorsAtIndexes:(NSIndexSet *)indexes withAuthors:(NSArray *)values;
- (void)addAuthorsObject:(Author *)value;
- (void)removeAuthorsObject:(Author *)value;
- (void)addAuthors:(NSOrderedSet *)values;
- (void)removeAuthors:(NSOrderedSet *)values;
- (void)addCorrespondenceAtObject:(Correspondence *)value;
- (void)removeCorrespondenceAtObject:(Correspondence *)value;
- (void)addCorrespondenceAt:(NSSet *)values;
- (void)removeCorrespondenceAt:(NSSet *)values;

@end
