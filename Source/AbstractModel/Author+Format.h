//Copyright (c) 2012-2015, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2015, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import "Author.h"

@interface Author (Format)
@property (nonatomic, readonly) NSString *fullName;
-(NSString *)formatName;
@end
