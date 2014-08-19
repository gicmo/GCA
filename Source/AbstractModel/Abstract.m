//
//  Abstract.m
//  GCA
//
//  Created by Christian Kellner on 19/08/14.
//  Copyright (c) 2014 G-Node. All rights reserved.
//

#import "Abstract.h"
#import "Affiliation.h"
#import "Author.h"
#import "Correspondence.h"
#import "Figure.h"
#import "Reference.h"


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

-(NSString *)session {
    int32_t gid = (self.aid & 0xFFFF0000) >> 16;

    NSString *groupPref = nil;
    switch (gid) {
        case 0:
            groupPref =  @"I";
            break;
        case 1:
            groupPref =  @"C";
            break;
        case 2:
            groupPref =  @"W";
            break;
        case 3:
            groupPref =  @"T";
            break;
        default:
            groupPref =  @"N";
            break;
    }

    return groupPref;
}

@end
