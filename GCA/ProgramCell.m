//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "ProgramCell.h"

@interface ProgramCell ()
@end

@implementation ProgramCell
@synthesize time = _time;
@synthesize session = _session;
@synthesize title = _title;
@synthesize person = _person;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setEvent:(NSDictionary *) event
{
    self.time.text = [event objectForKey:@"time"];
    self.title.text = [event objectForKey:@"title"];
    self.session.text = nil;
    
    if ([[event objectForKey:@"type"] isEqual:@"food"]) {
        self.title.font = [UIFont systemFontOfSize:12.0];
        self.title.textAlignment = UITextAlignmentCenter;
        
        CGSize textSize = [self.title.text sizeWithFont:self.title.font];
        CGRect frame = self.title.frame;
        frame.size.height = textSize.height;
        frame.origin.y = 5;
        self.title.frame = frame;
        
    } else {
        self.title.font = [UIFont boldSystemFontOfSize:12.0];
        self.title.textAlignment = UITextAlignmentLeft;
        self.title.numberOfLines = 2;
    }
    
    if ([event objectForKey:@"id"] || [event objectForKey:@"info"]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *person = [event objectForKey:@"person"];
    
    if (person != nil) {
        self.person.text = person;
        self.person.hidden = NO;
    } else {
        self.person.hidden = YES;
    }
}


@end
