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

@class CKSchedule;


@interface CKTimePoint : NSObject
@property (nonatomic, readonly) NSInteger hour;
@property (nonatomic, readonly) NSInteger minute;

+ (CKTimePoint *) timePointFromComponents:(NSDateComponents *)comps;
- (instancetype) initWithHour:(NSInteger)hour andMinute:(NSInteger)minute;


- (BOOL)isEqualToTimePoint:(CKTimePoint *)timePoint;
- (BOOL)isEqual:(id)object;


@end

@interface CKDate : NSObject
@property (nonatomic, readonly) NSInteger day;
@property (nonatomic, readonly) NSInteger month;
@property (nonatomic, readonly) NSInteger year;

+ (CKDate *) dateFromComponents:(NSDateComponents *)comps;
- (instancetype) initFromComponents:(NSDateComponents *)comps;

- (BOOL)isEqualToDate:(CKDate *)date;
- (BOOL)isEqual:(id)object;
@end


@interface CKScheduleItem : NSObject
@property kCKEventType eventType;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

@property (nonatomic, weak, readonly) CKSchedule *schedule;

- (CKDate *)date;
@end

@interface CKEvent : CKScheduleItem
@property (nonatomic, readonly) CKDate *date;
@property (nonatomic, readonly) CKTimePoint *begin;
@property (nonatomic, readonly) CKTimePoint *end;
@property (nonatomic, readonly) NSString *info;
@end


@interface CKSession : CKScheduleItem
@property (nonatomic, strong) NSArray *tracks;
@end


@interface CKTrack : CKScheduleItem
@property (nonatomic, strong) NSString *chair;
@property (nonatomic, strong) NSArray *events;

- (CKDate *)date;
@end


@interface CKTalkEvent : CKEvent
@property (nonatomic, strong) NSString *chair;
@property (nonatomic, strong) NSArray *authors; //NSStrings for now
@property (nonatomic, strong) NSString *abstract; //uuid of abstract
@end


@interface CKDay : NSObject
@property (nonatomic, strong, readonly) CKDate *date;
@property (nonatomic, strong) NSArray *events;
@end

@interface CKSchedule : NSObject
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong, readonly) NSArray *days;

- (instancetype) initFromFile:(NSString *)path;

@end
