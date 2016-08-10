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

#import "Conference+Groups.h"


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
    Group *group = [self.conference groupForSortID:self.aid];
    
    if (group == nil) {
        NSLog(@"[W] no group found for abstract: %@", self.uuid);
        return @"Unknown";
    }
    return [NSString stringWithFormat:@"%@", group.name];
}

@end
