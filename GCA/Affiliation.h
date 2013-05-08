//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Author, Organization;

@interface Affiliation : NSManagedObject

@property (nonatomic, retain) Abstract *forAbstract;
@property (nonatomic, retain) NSSet *ofAuthors;
@property (nonatomic, retain) Organization *toOrganization;
@end

@interface Affiliation (CoreDataGeneratedAccessors)

- (void)addOfAuthorsObject:(Author *)value;
- (void)removeOfAuthorsObject:(Author *)value;
- (void)addOfAuthors:(NSSet *)values;
- (void)removeOfAuthors:(NSSet *)values;

@end
