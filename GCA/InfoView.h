//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import <UIKit/UIKit.h>

@interface InfoView : UIView
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) UIColor *fgColor;

- (void) resetFormat;
@end
