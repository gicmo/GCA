//
//  Organization+Format.m
//  AbstractManager
//
//  Created by Christian Kellner on 19/08/14.
//  Copyright (c) 2014 G-Node. All rights reserved.
//

#import "Organization+Format.h"

@implementation Organization (Format)
-(NSString *)mkString
{
    NSMutableArray *components = [[NSMutableArray alloc] init];

    if (self.department && self.department.length) {
        [components addObject:self.department];
    }

    if (self.section && self.section.length) {
        [components addObject:self.section];
    }

    if (self.address && self.address.length) {
        [components addObject:self.address];
    }

    if (self.country && self.country.length) {
        [components addObject:self.country];
    }

    return [components componentsJoinedByString:@", "];
}
@end
