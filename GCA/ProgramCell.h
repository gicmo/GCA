//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import <UIKit/UIKit.h>

@interface ProgramCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *time;
@property (nonatomic, strong) IBOutlet UILabel *session;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *person;

- (void)setEvent:(NSDictionary *) event;

@end
