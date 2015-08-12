//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import "Abstract+Format.h"
#import "Conference.h"
#import "Group.h"

@implementation Abstract (Format)

- (int32_t)groupId
{
    return (self.aid & (0xFFFF << 16)) >> 16;
}

- (int32_t)abstractId
{
    return self.aid & 0xFFFF;
}

- (NSString *) formatId:(BOOL)withSpace
{
    int32_t aid = self.abstractId;
    int32_t gid = self.groupId;

    NSString *brief = @"?";
    for (Group *g in self.conference.groups) {
        if (g.prefix == gid) {
            brief = g.brief;
            break;
        }
    }

    NSString *str = [NSString stringWithFormat:@"%@%s%d",
                     brief,
                     withSpace ? " " : "", aid];
    return str;
}

@end
