//
//  AbstractView.m
//  GCA
//
//  Created by Christian Kellner on 8/29/12.
//
//

#import <CoreText/CoreText.h>

#import "AbstractView.h"
#import "Author.h"
#import "Organization.h"
#import "Affiliation.h"
#import "Correspondence.h"

@interface NSMutableAttributedString (Append)

-(void)appendString:(NSString *)string attributes:(NSDictionary *)attr;

@end

@implementation NSMutableAttributedString (Append)

-(void)appendString:(NSString *)string attributes:(NSDictionary *)attr
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attr];
    [self appendAttributedString:attrString];
}

@end

@interface AbstractView ()
{
    CTFramesetterRef frameSetter;
}

@property (nonatomic, strong) NSAttributedString *formatedString;

@end


@implementation AbstractView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (id)initWithFrame:(CGRect)frame andAbstract:(Abstract *) abstract
{
    self = [super initWithFrame:frame];
    if (self) {
        self.abstract = abstract;
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

-(void) setAbstract:(Abstract *)abstract
{
    _abstract = abstract;
    [self updateFrameSetter];
    [self setNeedsDisplay];
}

- (void)updateFrameSetter
{
    
    Abstract *abstract = self.abstract;
    NSMutableAttributedString *strBuilder = [[NSMutableAttributedString alloc] init];
    self.formatedString = strBuilder;
    if (abstract == nil)
        return;
    
    NSLog(@"updateFrameSetter...");
    
    /* create all attributes (fonts) */
    UIFont *font = [UIFont boldSystemFontOfSize:13.0];
    CTFontRef titleFont = CTFontCreateWithName((__bridge CFStringRef) font.fontName,
                                               font.pointSize,
                                               NULL);
    
    NSDictionary *titleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                               (__bridge id)titleFont, kCTFontAttributeName,
                               nil];
    
    font = [UIFont boldSystemFontOfSize:13.0];
    CTFontRef authorFont = CTFontCreateWithName((__bridge CFStringRef) font.fontName,
                                                font.pointSize,
                                                NULL);
    
    NSDictionary *authorAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                               (__bridge id)titleFont, kCTFontAttributeName,
                               nil];
    
    font = [UIFont boldSystemFontOfSize:13.0];
    CTFontRef affiliationFont = CTFontCreateWithName((__bridge CFStringRef) font.fontName,
                                                     font.pointSize,
                                                     NULL);
    
    font = [UIFont systemFontOfSize:13.0];
    CTFontRef epithetFont = CTFontCreateWithName((__bridge CFStringRef) @"Hoefler Text",
                                              font.pointSize,
                                              NULL);
    NSDictionary *epithetAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)((__bridge CFNumberRef)[NSNumber numberWithInt:1]), kCTSuperscriptAttributeName,
                                (__bridge id)epithetFont, kCTFontAttributeName,
                                nil];

    
    font = [UIFont boldSystemFontOfSize:13.0];
    CTFontRef corrFont = CTFontCreateWithName((__bridge CFStringRef) font.fontName,
                                              font.pointSize,
                                              NULL);
    
    font = [UIFont boldSystemFontOfSize:13.0];
    CTFontRef textFont = CTFontCreateWithName((__bridge CFStringRef) font.fontName,
                                              font.pointSize,
                                              NULL);
    
    font = [UIFont boldSystemFontOfSize:13.0];
    CTFontRef apHeadingFont = CTFontCreateWithName((__bridge CFStringRef) font.fontName,
                                                   font.pointSize,
                                                   NULL);
    font = [UIFont boldSystemFontOfSize:13.0];
    CTFontRef appTextFont = CTFontCreateWithName((__bridge CFStringRef) font.fontName,
                                                   font.pointSize,
                                                   NULL);
    
    
    NSString *string = [NSString stringWithFormat:@"%@\n", abstract.title];
    [strBuilder appendString:string attributes:titleAttr];
    
    for (Author *author in abstract.authors) {
        [strBuilder appendString:author.name attributes:authorAttr];
        NSMutableString *epithat = [[NSMutableString alloc] init];
        
        for (NSUInteger i = 0; i < abstract.affiliations.count; i++) {
            Affiliation *affiliation = [abstract.affiliations objectAtIndex:i];
            if ([affiliation.ofAuthors containsObject:author]) {
                [epithat appendFormat:@"%s%u", i != 0 ? "," : "", i+1];
            }
        }
        
        for (Correspondence *cor in abstract.correspondenceAt) {
            if (cor.ofAuthor == author)
                [epithat appendString:@"*"];
        }

        [strBuilder appendString:epithat attributes:epithetAttr];
    }

    if (frameSetter)
        CFRelease(frameSetter);

    //strBuilder = [[NSAttributedString alloc] initWithString:@"Test"];
    frameSetter = CTFramesetterCreateWithAttributedString ((__bridge CFAttributedStringRef) strBuilder);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSLog(@" !! drawRect\n");
    
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
