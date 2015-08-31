//Copyright (c) 2012-2015, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2015, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import "Organization+Format.h"

@implementation Organization (Format)
-(NSString *)mkString
{
    NSMutableArray *components = [[NSMutableArray alloc] init];

    if (self.department && self.department.length) {
        [components addObject:self.department];
    }

    if (self.section && self.section.length) {
        [components addObject:self.section];
    }

    if (self.address && self.address.length) {
        [components addObject:self.address];
    }

    if (self.country && self.country.length) {
        [components addObject:self.country];
    }

    return [components componentsJoinedByString:@", "];
}
@end
