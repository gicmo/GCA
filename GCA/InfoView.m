//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "InfoView.h"
#import <CoreText/CoreText.h>
#import <CoreText/CTFramesetter.h>

#import "NSAttributedString+GSX.h"

@interface InfoView () {
    CTFramesetterRef frameSetter;
}

@property NSMutableDictionary *format;
@end

@implementation InfoView
@synthesize data = _data;
@synthesize fgColor = _fgColor;

- (NSMutableDictionary *) getDefaultFormat
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    
    /* section */
    UIFont *font = [UIFont boldSystemFontOfSize:13.0];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef) font.fontName,
                                            font.pointSize,
                                            NULL);
    NSMutableDictionary *section = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    (id)self.fgColor.CGColor, kCTForegroundColorAttributeName,
                                    ctFont, kCTFontAttributeName,
                                    nil];
    
    [options setObject:section forKey:@"section"];
    
    /* text */
    font = [UIFont systemFontOfSize:12.0];
    ctFont = CTFontCreateWithName((__bridge CFStringRef) font.fontName,
                                            font.pointSize,
                                            NULL);
    
    NSMutableDictionary *textFormat = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       (id)self.fgColor.CGColor, kCTForegroundColorAttributeName,
                                       ctFont, kCTFontAttributeName,
                                       nil];
    [options setObject:textFormat forKey:@"text"];
    
    return options;
}

-(void)resetFormat
{
    self.fgColor = [UIColor blackColor];
    self.format = [self getDefaultFormat];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self resetFormat];
    }
    return self;
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

- (void) setFgColor:(UIColor *)fgColor
{
    _fgColor = fgColor;
    
    [self.format enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [obj setObject:(id)fgColor.CGColor forKey:(id)kCTForegroundColorAttributeName];
    }];
    
    [self refresh];
}

- (void) setData:(NSData *)data
{
    _data = data;
    [self refresh];
}

- (void)refresh
{
    if (self.data == nil) {
        return;
    }
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithGSX:self.data
                                                            andFormat:self.format];
    if (frameSetter)
        CFRelease(frameSetter);
    
    frameSetter = CTFramesetterCreateWithAttributedString ((__bridge CFAttributedStringRef) str);
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
}

- (void) dealloc
{
    if (frameSetter)
        CFRelease (frameSetter);
}

@end
