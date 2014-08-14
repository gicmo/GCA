//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "Abstract+Utils.h"

@implementation Abstract (Utils)

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
    
    NSString *str = [NSString stringWithFormat:@"%@%s%d",
                     [Abstract formatGroupId:self.groupId],
                     withSpace ? " " : "",
                     self.abstractId];
    return str;
}

- (NSString *) figureIdForFigure:(NSInteger)idx ofNFigures:(NSInteger)nfigures
{
    NSString *groupString = [[Abstract formatGroupId:self.groupId] lowercaseString];
    
    char suffix = '\0';
    
    if (nfigures > 1) {
        suffix = 'a' + idx;
    }
    
    NSString *str = [NSString stringWithFormat:@"%@%02d%c.jpg",
                     groupString,
                     self.abstractId,
                     suffix];
    return str;
}

@end
