//Copyright (c) 2012-2014, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2014, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import "Abstract.h"

@interface Abstract (Format)
@property (nonatomic, readonly) int32_t abstractId;
@property (nonatomic, readonly) int32_t groupId;

- (NSString *) formatId:(BOOL)withSpace;
@end
