//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "Abstract.h"
#import "Affiliation.h"
#import "Author.h"
#import "Correspondence.h"


@implementation Abstract

@dynamic acknoledgements;
@dynamic aid;
@dynamic conflictOfInterests;
@dynamic frontid;
@dynamic frontsubid;
@dynamic isFavorite;
@dynamic nfigures;
@dynamic notes;
@dynamic references;
@dynamic text;
@dynamic title;
@dynamic topic;
@dynamic type;
@dynamic session;
@dynamic affiliations;
@dynamic authors;
@dynamic correspondenceAt;

-(NSString *)session {
    int32_t gid = (self.aid & (0xFFFF << 16)) >> 16;
    int32_t lid = self.aid & 0xFFFF;
    
    NSString *groupPref = nil;
    switch (gid) {
        case 0:
            groupPref =  @"U";
            break;
        case 1:
            groupPref =  @"O";
            break;
        case 2:
            groupPref =  @"W";
            break;
        case 3:
            groupPref =  @"T";
            break;
        case 4:
            groupPref =  @"F";
            break;
        default:
            groupPref =  @"N";
            break;
    }
    
    NSString *topString = self.topic;
    if (gid == 3 && lid < 8)
        topString = @"US-German Collaboration in Computational Neuroscience";

    return [NSString stringWithFormat:@"%@ %@", groupPref, topString];
}

@end
