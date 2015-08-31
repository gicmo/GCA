//Copyright (c) 2012-2015, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2015, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import "Author+Format.h"

@implementation Author (Format)

-(NSString *)formatName
{
    //FIXME
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

-(NSString *)fullName
{
    NSString *middle = self.middleName ?: @"";
    
    return [NSString stringWithFormat:@"%@ %@ %@",
            self.firstName, middle, self.lastName];
}

@end
