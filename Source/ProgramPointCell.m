//
//  ProgramPointCell.m
//  NI2013
//
//  Created by Christian Kellner on 18/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "ProgramPointCell.h"
#import "UIColor+ConferenceKit.h"

@interface ProgramPointCell ()
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorHeight;

@end

@implementation ProgramPointCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void) setEvent:(CKScheduleItem *)event
{
    self.title.text = event.title;
    if (event.subtitle && ![event.subtitle isEqualToString:@""]) {
        self.title.text = [NSString stringWithFormat:@"%@: %@", self.title.text, event.subtitle];
    }
    
    NSString *timeText = @"";
    if ([event isKindOfClass:[CKEvent class]]) {
        CKEvent *ev = (CKEvent *) event;
        
        if (ev.begin != nil) {
            timeText = [NSString stringWithFormat:@"%0.2ld:%0.2ld", (long)ev.begin.hour, (long)ev.begin.minute];
        }
        
        if ([event isKindOfClass:[CKTalkEvent class]]) {
            CKTalkEvent *tv = (CKTalkEvent *) event;
            self.author.text = [tv.authors componentsJoinedByString:@", "];
        }
        
    } else if ([event isKindOfClass:[CKTrack class]]) {
        CKTrack *track = (CKTrack *) event;
        self.author.text = track.chair;
    }
    
    self.time.text = timeText;
    self.time.textColor = [UIColor ckColor];
    
    [self setNeedsLayout];
}

#define NROW_ONE 36
#define NROW_TWO 57
#define NROW_THREE 83
#define NROW_FOUR 108

+(CGFloat)heightForEvent:(CKScheduleItem *)item;
{
    CKTrack *track = nil;
    CKTalkEvent *talk = nil;
    
    switch (item.eventType) {
        case ET_TALK:
            talk = (CKTalkEvent *)item;
            if (talk.authors.count > 0) {
                return NROW_TWO;
            } else {
                return NROW_ONE;
            }
        case ET_TRACK:
            track = (CKTrack *)item;
            if (track.chair && ![track.chair isEqualToString:@""]) {
                return NROW_TWO;
            } else {
                return NROW_ONE;
            }
        default:
            return NROW_ONE;
    }
}


@end
