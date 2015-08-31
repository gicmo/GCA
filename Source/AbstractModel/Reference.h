//Copyright (c) 2012-2015, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2015, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract;

@interface Reference : NSManagedObject

@property (nonatomic, retain) NSString * doi;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) Abstract *ofAbstract;

@end
