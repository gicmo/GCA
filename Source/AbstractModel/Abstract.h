//
//  Abstract.h
//  GCA
//
//  Created by Christian Kellner on 19/08/14.
//  Copyright (c) 2014 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Affiliation, Author, Correspondence, Figure, Reference;

@interface Abstract : NSManagedObject

@property (nonatomic, retain) NSString * acknoledgements;
@property (nonatomic) int32_t aid;
@property (nonatomic) int32_t altid;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * conflictOfInterests;
@property (nonatomic, retain) NSString * doi;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) int32_t nfigures;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * session;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSOrderedSet *affiliations;
@property (nonatomic, retain) NSOrderedSet *authors;
@property (nonatomic, retain) NSSet *correspondenceAt;
@property (nonatomic, retain) NSOrderedSet *figures;
@property (nonatomic, retain) NSOrderedSet *references;
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

- (void)insertObject:(Figure *)value inFiguresAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFiguresAtIndex:(NSUInteger)idx;
- (void)insertFigures:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFiguresAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFiguresAtIndex:(NSUInteger)idx withObject:(Figure *)value;
- (void)replaceFiguresAtIndexes:(NSIndexSet *)indexes withFigures:(NSArray *)values;
- (void)addFiguresObject:(Figure *)value;
- (void)removeFiguresObject:(Figure *)value;
- (void)addFigures:(NSOrderedSet *)values;
- (void)removeFigures:(NSOrderedSet *)values;
- (void)insertObject:(Reference *)value inReferencesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReferencesAtIndex:(NSUInteger)idx;
- (void)insertReferences:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReferencesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReferencesAtIndex:(NSUInteger)idx withObject:(Reference *)value;
- (void)replaceReferencesAtIndexes:(NSIndexSet *)indexes withReferences:(NSArray *)values;
- (void)addReferencesObject:(Reference *)value;
- (void)removeReferencesObject:(Reference *)value;
- (void)addReferences:(NSOrderedSet *)values;
- (void)removeReferences:(NSOrderedSet *)values;
@end
