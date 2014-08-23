//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import "Abstract+Format.h"

@implementation Abstract (Format)

- (int32_t)groupId
{
    return (self.aid & (0xFFFF << 16)) >> 16;
}

- (int32_t)abstractId
{
    return self.aid & 0xFFFF;
}

+ (NSString *) formatGroupId:(int32_t) groupId
{
    switch (groupId) {
        case 0:
            return @"I";
            break;
        case 1:
            return @"C";
            
        case 2:
            return @"W";
            
        case 3:
            return @"T";
        default:
            break;
    }
    
    return @"U";
}


- (NSString *) formatId:(BOOL)withSpace
{
    return [Abstract formatId:self.aid withSpaces:withSpace];
}


+ (NSString *) formatId:(int32_t)sortId withSpaces:(BOOL)withSpace
{
    int32_t aid = sortId & 0xFFFF;
    int32_t gid = (sortId & (0xFFFF << 16)) >> 16;
    NSString *str = [NSString stringWithFormat:@"%@%s%d",
                     [Abstract formatGroupId:gid],
                     withSpace ? " " : "", aid];
    return str;
}
@end
