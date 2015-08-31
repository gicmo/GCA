//Copyright (c) 2012-2015, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2015, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conference;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t prefix;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * brief;
@property (nonatomic, retain) Conference *conference;

@end
