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

-(void) setEvent:(NSDictionary *)event
{
    self.time.text = [event objectForKey:@"time"];
    self.time.textColor = [UIColor ckColor];
    
    NSString *eventType = event[@"type"];
    
    if ([eventType isEqualToString:@"general"] ||
        [eventType isEqualToString:@"food"]    ||
        [eventType isEqualToString:@"poster"]  ||
        [eventType isEqualToString:@"header"]) {
        self.title.text = event[@"title"];
        self.author.hidden = YES;
    } else if ([eventType isEqualToString:@"talk"] ||
               [eventType isEqualToString:@"ctalk"]) {
        self.author.text = event[@"speaker"];
        self.author.hidden = NO;
        self.title.text = event[@"title"];
    } else if ([eventType isEqualToString:@"session"]) {
        if (event[@"chair"]) {
            self.author.hidden = NO;
            self.author.text = [NSString stringWithFormat:@"Chair: %@", event[@"chair"]];
        } else {
            self.author.hidden = YES;
        }
        
        self.title.text = event[@"title"];
    } else {
        self.title.text = event[@"title"];
        self.author.hidden = YES;
    }
    
    if ([eventType isEqualToString:@"talk"] ||
        [eventType isEqualToString:@"ctalk"]) {
        self.titleHeight.constant = 50.0;
        self.title.numberOfLines = 2;
    } else {
        self.titleHeight.constant = 25.0;
        self.title.numberOfLines = 1;
    }
    
    if ([eventType isEqualToString:@"ctalk"]) {
        self.authorHeight.constant = 50.0;
        self.author.numberOfLines = 2;
    } else {
        self.authorHeight.constant = 25.0;
        self.author.numberOfLines = 1;
    }
    
    if ([eventType isEqualToString:@"food"]) {
        self.title.textColor = [UIColor ckColor];
    } else {
        self.title.textColor = [UIColor darkGrayColor];
    }
    
    
    [self setNeedsLayout];
}

#define NROW_ONE 36
#define NROW_TWO 57
#define NROW_THREE 83
#define NROW_FOUR 108

+(CGFloat)heightForEvent:(NSDictionary *)event
{
    NSString *eventType = event[@"type"];
    
    if ([eventType isEqualToString:@"talk"]) {
        return NROW_THREE;
    } else if ([eventType isEqualToString:@"ctalk"]) {
        return NROW_FOUR;
    } else if ([eventType isEqualToString:@"session"] && event[@"chair"]) {
        return NROW_TWO;
    }
    
    return NROW_ONE;
}


@end
