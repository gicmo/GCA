//
//  WorkshopCell.m
//  NI2013
//
//  Created by Christian Kellner on 19/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "WorkshopCell.h"
#import "UIColor+ConferenceKit.h"

@interface WorkshopCell ()
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *heading;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *chair;
@property (weak, nonatomic) IBOutlet UILabel *speakers;

@property (weak, nonatomic) IBOutlet UILabel *chairLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVspeakers;
@end

@implementation WorkshopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

#define CONSTRAINT_VSPEAKERS_DEFAULT 112
#define CONSTRAINT_VSPEAKERS_NOCHAIR 65
-(void)setEvent:(NSDictionary *)event
{
    self.time.textColor = [UIColor ckColor];
    self.time.text = event[@"time"];
    
    self.heading.text = event[@"header"];
    self.title.text = event[@"title"];
    
    self.chair.text = event[@"chair"];

    BOOL chairLabelState =  self.chairLabel.hidden;
    if (!event[@"chair"]) {
        self.chairLabel.hidden = YES;
        self.constraintVspeakers.constant = CONSTRAINT_VSPEAKERS_NOCHAIR;
    } else {
        self.chairLabel.hidden = NO;
        self.constraintVspeakers.constant = CONSTRAINT_VSPEAKERS_DEFAULT;
    }
    
    if (chairLabelState != self.chairLabel.hidden) {
        [self setNeedsLayout];
    }
    
    NSMutableString *speakersText = [[NSMutableString alloc] initWithString:@""];
    NSArray *speakers = event[@"speakers"];
    
    for (NSString *speaker in speakers) {
        [speakersText appendFormat:@"%@\n", speaker];
    }
    
    self.speakers.text = speakersText;
    self.speakers.numberOfLines = speakers.count;
}

+(CGFloat)heightForEvent:(NSDictionary *)event
{
    static CGFloat defaultHeight = 215;
    if (event[@"chair"]) {
        return defaultHeight;
    } else {
        return defaultHeight - (CONSTRAINT_VSPEAKERS_DEFAULT -
                                CONSTRAINT_VSPEAKERS_NOCHAIR);
    }
}

@end
