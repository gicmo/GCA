//
//  Conference+Groups.m
//  GCA
//
//  Created by Christian Kellner on 10/08/2016.
//  Copyright © 2016 G-Node. All rights reserved.
//

#import "Conference+Groups.h"

@implementation Conference (Groups)
-(Group *)groupForSortID:(uint32_t)aid {
    int32_t gid = (aid & (0xFFFF << 16)) >> 16;
    
    Group *res = nil;
    for (Group *g in self.groups) {
        if (g.prefix == gid) {
            res = g;
            break;
        }
    }
    
    return res;
}

@end
