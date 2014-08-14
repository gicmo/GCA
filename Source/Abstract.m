//
//  Abstract.m
//  AbstractManager
//
//  Created by Christian Kellner on 17/09/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "Abstract.h"
#import "Affiliation.h"
#import "Author.h"
#import "Correspondence.h"


@implementation Abstract

@dynamic acknoledgements;
@dynamic aid;
@dynamic altid;
@dynamic conflictOfInterests;
@dynamic doi;
@dynamic figid;
@dynamic isFavorite;
@dynamic nfigures;
@dynamic notes;
@dynamic references;
@dynamic session;
@dynamic text;
@dynamic title;
@dynamic topic;
@dynamic type;
@dynamic caption;
@dynamic affiliations;
@dynamic authors;
@dynamic correspondenceAt;

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
