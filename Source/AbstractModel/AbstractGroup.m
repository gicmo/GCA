//
//  AbstractGroup.m
//  AbstractManager
//
//  Created by Christian Kellner on 8/28/12.
//  Copyright (c) 2012 G-Node. All rights reserved.
//

#import "AbstractGroup.h"

@implementation AbstractGroup
@synthesize abstracts = _abstracts;
@synthesize type = _type;
@synthesize name = _name;

+ (AbstractGroup *) groupWithType:(GroupType)groupType
{
    AbstractGroup *group = [[AbstractGroup alloc] init];
    group.type = groupType;
    return group;
}

- (NSMutableOrderedSet *)abstracts
{
    if (_abstracts == nil) {
        _abstracts = [[NSMutableOrderedSet alloc] init];
    }
    return _abstracts;
}

+ (AbstractGroup *) groupWithUID:(uint8_t)uid andName:(NSString *)name
{
    AbstractGroup *group = [[AbstractGroup alloc] init];
    
    group.type = uid;
    group.name = name;
    
    return group;
}

@end