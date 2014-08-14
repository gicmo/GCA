//
//  CKMarkdownView.m
//  INCF 13
//
//  Created by Christian Kellner on 16/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "CKMarkdownView.h"
#import <CoreText/CoreText.h>
#import "UIColor+ConferenceKit.h"

@interface CKMarkdownView () {
    CTFramesetterRef frameSetter;
}
@end


@implementation CKMarkdownView

-(id)init
{
    self = [super init];
    if (self) {
        //self.fgColor = [UIColor whiteColor];
        //self.backgroundColor = [UIColor ckColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.fgColor = [UIColor whiteColor];
    }
    return self;
}


- (void) setFgColor:(UIColor *)fgColor
{
    _fgColor = fgColor;
    [self refresh];
}

-(void)setText:(NSAttributedString *)text
{
    _text = text;
    [self refresh];
}

- (CGSize) sizeThatFits:(CGSize)size
{
    CFRange range = CFRangeMake(0, 0);
    CFRange suggest;
    CGSize fit = CTFramesetterSuggestFrameSizeWithConstraints (frameSetter,
                                                               range,
                                                               NULL,
                                                               size,
                                                               &suggest);
    return fit;
}

- (void)refresh
{
    if (frameSetter) {
        CFRelease(frameSetter);
        frameSetter = nil;
    }
    
    if (self.text == nil) {
        return;
    }
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.text];
    NSMutableDictionary *textFormat = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       (id)self.fgColor, kCTForegroundColorAttributeName,
                                       nil];
    
    [attrStr size];
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttributes:textFormat range:range];
    
    frameSetter = CTFramesetterCreateWithAttributedString ((__bridge CFAttributedStringRef)
                                                           attrStr);
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (frameSetter == NULL)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix (context, CGAffineTransformIdentity);
    CGContextTranslateCTM (context, 0, self.bounds.size.height);
    CGContextScaleCTM (context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect (path, NULL, self.bounds);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter,
                                                CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw (frame, context);
    CFRelease (frame);
    CGPathRelease(path);
}

- (void) dealloc
{
    if (frameSetter)
        CFRelease (frameSetter);
}

@end
