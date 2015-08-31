//Copyright (c) 2012-2015, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2015, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import "Abstract.h"
#import "Affiliation.h"
#import "Author.h"
#import "Conference.h"
#import "Correspondence.h"
#import "Figure.h"
#import "Reference.h"
#import "Group.h"


@implementation Abstract

@dynamic acknoledgements;
@dynamic aid;
@dynamic altid;
@dynamic caption;
@dynamic conflictOfInterests;
@dynamic doi;
@dynamic isFavorite;
@dynamic nfigures;
@dynamic notes;
@dynamic session;
@dynamic text;
@dynamic title;
@dynamic topic;
@dynamic type;
@dynamic uuid;
@dynamic affiliations;
@dynamic authors;
@dynamic correspondenceAt;
@dynamic figures;
@dynamic references;
@dynamic conference;

-(NSString *)session {

    NSString *sep = self.topic != nil ? @" - " : @"";
    int32_t gid = (self.aid & (0xFFFF << 16)) >> 16;
    NSString *name;
    NSString *topic = self.topic ?: @"";

    for (Group *g in self.conference.groups) {
        if (g.prefix == gid) {
            name = g.name;
            break;
        }
    }

    return [NSString stringWithFormat:@"%@%@%@", name, sep, topic];
}

@end
