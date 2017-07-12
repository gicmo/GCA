//
//  UIColor+ConferenceKit.m
//  INCF 13
//
//  Created by Christian Kellner on 16/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "UIColor+ConferenceKit.h"

@implementation UIColor (ConferenceKit)

+ (UIColor *)ckColor
{
     return [UIColor colorWithRed:0.0235 green:0.2510 blue:0.5098 alpha:1.0000];
}

+ (UIColor *)incfBlack
{
    return [UIColor colorWithRed:0.145 green:0.145 blue:0.145 alpha:1.0000];
}

- (NSString *)hexString {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}
@end
