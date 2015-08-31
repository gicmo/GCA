//Copyright (c) 2012-2015, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2015, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Author;

@interface Correspondence : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) Abstract *forAbstract;
@property (nonatomic, retain) Author *ofAuthor;

@end
