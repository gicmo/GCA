//
//  CKSchedule.m
//  GCA
//
//  Created by Christian Kellner on 10/08/2015.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import "CKSchedule.h"

@interface CKScheduleItem()
-(instancetype) initFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule;
@end

@interface CKEvent()
+(CKEvent *) eventFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule;
-(instancetype) initFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule;
@end

@interface CKTalkEvent()
- (instancetype) initFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule;
@end

@interface CKTrack()
- (instancetype) initFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule;
@end

@interface CKSchedule()
@property (atomic, strong) NSDateFormatter *dayFormatter;
@property (atomic, strong) NSDateFormatter *timePointFormatter;

- (CKDay *)dayForDate:(CKDate *)date;
- (CKDay *)dayForString:(NSString *)dateString;
- (CKDate *)dateForString:(NSString *)dateString;
- (CKTimePoint *)timePointForString:(NSString *)timeString;
@end

@interface CKDay()
- (instancetype) initFromDate:(CKDate *)date;
- (void) addEvents:(NSArray *)events;
@end

/**********************************************************/

@implementation CKDate
+(CKDate *) dateFromComponents:(NSDateComponents *)comps {
    CKDate *date = [[CKDate alloc] initFromComponents:comps];
    return date;
}

- (instancetype) initFromComponents:(NSDateComponents *)comps {
    self = [super init];
    if (!self) {
        return self;
    }
    
    _year = comps.year;
    _month = comps.month;
    _day = comps.day;
    
    return self;
}

- (BOOL)isEqualToDate:(CKDate *)date {
    if (self == date) {
        return YES;
    }
    
    return self.year == date.year &&
           self.month == date.month &&
           self.day == date.day;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    } else if(!object || ![object isKindOfClass:[self class]]) {
        return NO;
    } else {
        return [self isEqualToDate:object];
    }
}

@end

@implementation CKTimePoint

+ (CKTimePoint *) timePointFromComponents:(NSDateComponents *)comps {
    CKTimePoint *point = [[CKTimePoint alloc] initFromComponents:comps];
    return point;
}

- (instancetype) initFromComponents:(NSDateComponents *)comps {
    self = [super init];
    if (!self) {
        return self;
    }
    
    _hour = comps.hour;
    _minute = comps.minute;
    
    return self;
}

- (BOOL)isEqualToTimePoint:(CKTimePoint *)point {
    if (self == point) {
        return YES;
    }
    
    return self.hour == point.hour &&
           self.minute == point.minute;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    } else if(!object || ![object isKindOfClass:[self class]]) {
        return NO;
    } else {
        return [self isEqualToTimePoint:object];
    }
}

@end

@implementation CKScheduleItem

-(instancetype) initFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule
{
    self = [super init];
    
    if (!self) {
        return self;
    }
    
    _schedule = schedule;
    self.title = dict[@"title"];
    self.subtitle = dict[@"subtitle"];
    self.eventType = ET_EVENT;
    
    return self;
}

-(CKDate *)date {
    return nil;
}

@end

@implementation CKEvent

+(CKEvent *) eventFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule {
    NSString *typeStr = dict[@"type"];
    
    CKEvent *ev;
    if ([typeStr isEqualToString:@"talk"]) {
        ev = [[CKTalkEvent alloc] initFromDict:dict forSchedule:schedule];
    } else if ([typeStr isEqualToString:@"food"] ||
               [typeStr isEqualToString:@"poster"]) {
        ev = [[CKEvent alloc] initFromDict:dict forSchedule:schedule];
    } else {
        ev = nil;
    }
    
    return ev;
}

-(instancetype) initFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule {
    self = [super initFromDict:dict forSchedule:schedule];;
    
    if (!self) {
        return self;
    }

    self.eventType = ET_FOOD;
    _date = [schedule dateForString:dict[@"date"]];
    _begin = [schedule timePointForString:dict[@"start"]];
    _end = [schedule timePointForString:dict[@"end"]];
    
    return self;
}

@end


@implementation CKTalkEvent

-(instancetype) initFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule{
    self = [super initFromDict:dict forSchedule:schedule];
    
    if (!self) {
        return self;
    }
    
    self.authors = dict[@"authors"];
    self.chair = dict[@"chair"];
    self.eventType = ET_TALK;
    
    return self;
}

@end


@implementation CKTrack

-(instancetype) initFromDict:(NSDictionary *)dict forSchedule:(CKSchedule *)schedule{
    self = [super initFromDict:dict forSchedule:schedule];
    
    if (!self) {
        return self;
    }

    NSMutableArray *events = [[NSMutableArray alloc] init];
    NSDictionary *eventsDict = dict[@"events"];
    for (NSDictionary *subEvent in eventsDict) {
        CKEvent *event = [CKEvent eventFromDict:subEvent forSchedule:schedule];
        if (event == nil) {
            NSLog(@"Could not parse event. Skipping!");
            continue;
        }
        
        [events addObject:event];
    }
    
    self.events = [events copy];
    self.eventType = ET_TRACK;
    self.chair = dict[@"chair"];
    return self;
}

- (CKDate *)date {
    
    CKDate *d = nil;
    
    if (self.events.count > 0) {
        CKEvent *ev = self.events[0];
        d = ev.date;
    }
    
    return d;
}

@end


@implementation CKDay
- (instancetype) initFromDate:(CKDate *)date {
    self = [super init];
    if (!self) {
        return self;
    }

    _date = date;
    
    return self;
}


- (void) addEvents:(NSArray *)items {

    NSMutableArray *ar = [NSMutableArray arrayWithArray:self.events];
    [ar addObjectsFromArray:items];
    
    _events = [ar copy];
}
@end

/**********************************************************/


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
        return nil;
    }
    
    self.dayFormatter = [[NSDateFormatter alloc] init];
    [self.dayFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.timePointFormatter = [[NSDateFormatter alloc] init];
    [self.timePointFormatter setDateFormat:@"HH:mm"];
    
    NSMutableArray *events = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in root) {
        NSString *typeStr = dict[@"type"];
        
        CKScheduleItem *item;
        if (typeStr != nil) {
            CKEvent *ev = [CKEvent eventFromDict:dict forSchedule:self];
            item = ev;
            CKDay *d = [self dayForDate:[ev date]];
            [d addEvents:@[item]];
        } else if (dict[@"events"] != nil) {
            CKTrack *track = [[CKTrack alloc] initFromDict:dict forSchedule:self];
            item = track;
            
            CKDay *d = [self dayForDate:[item date]];
            [d addEvents:@[item]];
            [d addEvents:track.events];
        } else {
            //Session, currently not supported
            NSLog(@"Unspported item, skipping");
            item = nil;
        }
        
        if (item != nil) {
            [events addObject:item];
        }
    }
    
    self.items = events;
    return self;
}

- (CKDay *)dayForDate:(CKDate *)date {
    
    if (date == nil) {
        return nil;
    }
    
    CKDay *day = nil;
    for (CKDay *cur in self.days) {
        if ([cur.date isEqualToDate:date]) {
            day = cur;
            break;
        }
    }
    
    if (day == nil) {
        NSMutableArray *new_days = [[NSMutableArray alloc] initWithArray:self.days];
        day = [[CKDay alloc] initFromDate:date];
        [new_days addObject:day];
        _days = [new_days copy];
    }
    
    return day;
}

- (CKDay *)dayForString:(NSString *)dateString {
    
    if (dateString == nil) {
        return nil;
    }
    
    CKDate *needle = [self dateForString:dateString];
    return [self dayForDate:needle];
}

- (CKDate *)dateForString:(NSString *)dateString {
    
    if (dateString == nil || [dateString isEqualToString:@""]) {
        return nil;
    }
    
    NSDate *date = [self.dayFormatter dateFromString:dateString];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [currentCalendar components:(NSCalendarUnitDay |
                                                           NSCalendarUnitMonth |
                                                           NSCalendarUnitYear) fromDate:date];
    
    return [CKDate dateFromComponents:comps];
}

- (CKTimePoint *)timePointForString:(NSString *)timeString {
    
    if (timeString == nil || [timeString isEqualToString:@""]) {
        return nil;
    }
    
    NSDate *date = [self.timePointFormatter dateFromString:timeString];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [currentCalendar components:(NSCalendarUnitHour |
                                                           NSCalendarUnitMinute) fromDate:date];
    return [CKTimePoint timePointFromComponents:comps];
}

@end
