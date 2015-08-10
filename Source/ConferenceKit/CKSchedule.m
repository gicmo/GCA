//
//  CKSchedule.m
//  GCA
//
//  Created by Christian Kellner on 10/08/2015.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import "CKSchedule.h"

@implementation CKEvent

-(instancetype) initFromDict:(NSDictionary *)dict
{
    self = [super init];
    
    if (!self) {
        return self;
    }
    
    self.title = dict[@"title"];
    self.subtitle = dict[@"subtitle"];
    self.eventType = ET_EVENT;
    
    return self;
}


+ (CKEvent *) eventFromDict:(NSDictionary *)dict
{
    NSString *typeStr = dict[@"type"];
    
    if (typeStr == NULL) {
        id subevents = dict[@"events"];
        if (subevents == NULL || ![subevents isKindOfClass:[NSArray class]]) {
            NSLog(@"Malform event [no type, no events]! Skipping");
            return NULL;
        }
        
        CKTrack *event = [[CKTrack alloc] initFromDict:dict];
        return event;
    } else if ([typeStr isEqualToString:@"talk"]) {
        CKTalkEvent *event = [[CKTalkEvent alloc] initFromDict:dict];
        return event;
    } else if ([typeStr isEqualToString:@"food"]) {
        CKEvent *event = [[CKEvent alloc] initFromDict:dict];
        event.eventType = ET_FOOD;
        return event;
    }
    
    return NULL;
}

@end


@implementation CKTalkEvent

-(instancetype) initFromDict:(NSDictionary *)dict {
    self = [super init];
    
    if (!self) {
        return self;
    }
    
    self.chair = dict[@"chair"];
    self.eventType = ET_TALK;
    
    return self;
}

@end


@implementation CKTrack

-(instancetype) initFromDict:(NSDictionary *)dict {
    self = [super init];
    
    if (!self) {
        return self;
    }

    NSMutableOrderedSet *events = [[NSMutableOrderedSet alloc] init];
    NSDictionary *eventsDict = dict[@"events"];
    for (NSDictionary *subEvent in eventsDict) {
        CKEvent *event = [CKEvent eventFromDict:subEvent];
        if (event == NULL) {
            continue;
        }
        
        [events addObject:event];
    }
    
    self.events = events;
    self.eventType = ET_TRACK;
    return self;
}

@end

@interface CKSchedule()

@end

@implementation CKSchedule
- (instancetype) initFromFile:(NSString *)path
{
    self = [super init];
    if (!self) {
        return self;
    }
    
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if (![root isKindOfClass:[NSArray class]]) {
        NSLog(@"Schedule JSON not a List! Abort parsing!");
        return NULL;
    }
    
    NSMutableOrderedSet *events = [[NSMutableOrderedSet alloc] init];
    for (NSDictionary *dict in root) {
        CKEvent *event = [CKEvent eventFromDict:dict];
        if (event == NULL) {
            continue;
        }
        
        [events addObject:event];
    }
    
    self.events = events;
    return self;
}


@end
