//Copyright (c) 2012-2015, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2015, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract;

@interface Figure : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) Abstract *ofAbstract;

@end
