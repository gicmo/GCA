//Copyright (c) 2012-2016, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2016, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Abstract, Group;

NS_ASSUME_NONNULL_BEGIN

@interface Conference : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

@protocol ConferenceAware <NSObject>
-(void) setConference:(Conference *)conf;
@end

#import "Conference+CoreDataProperties.h"
