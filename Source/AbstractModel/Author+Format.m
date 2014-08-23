//
//  Author+Format.m
//  AbstractManager
//
//  Created by Christian Kellner on 18/08/14.
//  Copyright (c) 2014 G-Node. All rights reserved.
//

#import "Author+Format.h"

@implementation Author (Format)

-(NSString *)formatName
{
    //FIXME
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

-(NSString *)fullName
{
    NSString *middle = self.middleName ?: @"";
    
    return [NSString stringWithFormat:@"%@ %@ %@",
            self.firstName, middle, self.lastName];
}

@end
