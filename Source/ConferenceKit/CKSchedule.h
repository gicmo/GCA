//
//  CKSchedule.h
//  GCA
//
//  Created by Christian Kellner on 10/08/2015.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ET_EVENT = 0,
    ET_TRACK = 1,
    ET_TALK = 2,
    ET_FOOD = 3
} kCKEventType;

@interface CKEvent : NSObject
@property kCKEventType eventType;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

- (instancetype) initFromDict:(NSDictionary *)dict;

+ (CKEvent *) eventFromDict:(NSDictionary *)dict;

@end


@interface CKTrack : CKEvent
@property (nonatomic, strong) NSString *chair;
@property (nonatomic, strong) NSOrderedSet *events;

- (instancetype) initFromDict:(NSDictionary *)dict;
@end

@interface CKTalkEvent : CKEvent
@property (nonatomic, strong) NSString *chair;
@property (nonatomic, strong) NSArray *authors; //NSStrings for now
@property (nonatomic, strong) NSString *abstract; //uuid of abstract

- (instancetype) initFromDict:(NSDictionary *)dict;
@end

@interface CKSchedule : NSObject
@property (nonatomic, strong) NSOrderedSet *events;

- (instancetype) initFromFile:(NSString *)path;

@end
