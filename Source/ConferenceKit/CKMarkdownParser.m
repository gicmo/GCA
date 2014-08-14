//
//  CKMarkdownParser.m
//  markdownview
//
//  Created by Christian Kellner on 25/07/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "CKMarkdownParser.h"
#import "markdown.h"


/* local help categories */

@interface NSString (MarkdownParser)
+ (NSString *) stringFromBuffer:(const struct buf *)buffer;
@end

@implementation NSString (MarkdownParser)
+ (NSString *) stringFromBuffer:(const struct buf *)buffer
{
    NSString *str = [[NSString alloc] initWithBytes:buffer->data
                                             length:buffer->size
                                           encoding:NSUTF8StringEncoding];
    return str;
}
@end

@interface NSAttributedString (MarkdownParser)
+ (NSAttributedString *) attributedStringFromBuffer:(const struct buf *)buffer;
+ (NSAttributedString *) attributedStringFromBuffer:(const struct buf *)buffer withAttributes:(NSDictionary *)attributes;
@end

@implementation NSAttributedString (MarkdownParser)
+ (NSAttributedString *) attributedStringFromBuffer:(const struct buf *)buffer
{
    NSString *str = [NSString stringFromBuffer:buffer];
    return [[NSAttributedString alloc] initWithString:str];
}
+ (NSAttributedString *) attributedStringFromBuffer:(const struct buf *)buffer withAttributes:(NSDictionary *)attributes
{
    NSAttributedString *attrString = [NSAttributedString alloc];
    NSString *str = [NSString stringFromBuffer:buffer];
    attrString = [attrString initWithString:str attributes:attributes];
    return attrString;
}
@end

/* **********************************************************************************   */

#pragma mark -
#pragma mark ParserContext

@interface ParserContext : NSObject
@property (nonatomic, strong) CKMarkdownParser *parser;
@property (nonatomic, strong) NSMutableAttributedString *text;

-(id)initWithParser:(CKMarkdownParser *)parser;
-(void)addTextFromBuffer:(const struct buf *)buffer;
-(void)addTextFromBuffer:(const struct buf *)buffer attributes:(NSDictionary *)attr;
-(void)addTextFromBuffer:(const struct buf *)buffer attributes:(NSDictionary *)attr addNewlines:(int)numberOfNewlines;
-(void)addNewlines:(int)numberOfNewlines;
@end


@implementation ParserContext
@synthesize parser;
@synthesize text;

-(id)initWithParser:(CKMarkdownParser *)aParser
{
    self = [self init];
    if (self) {
        self.parser = aParser;
        self.text = [[NSMutableAttributedString alloc] init];
    }
    
    return self;
}

-(void)addTextFromBuffer:(const struct buf *)buffer
{
    NSString *str = [NSString stringFromBuffer:buffer];
    [self.text appendAttributedString:[[NSAttributedString alloc] initWithString:str]];
    
}

-(void)addTextFromBuffer:(const struct buf *)buffer attributes:(NSDictionary *)attr
{
    return [self addTextFromBuffer:buffer attributes:attr addNewlines:0];
}

-(void)addTextFromBuffer:(const struct buf *)buffer attributes:(NSDictionary *)attr addNewlines:(int)numberOfNewlines
{
    NSString *str = [NSString stringFromBuffer:buffer];
    [self.text appendAttributedString:[[NSAttributedString alloc]
                                       initWithString:str attributes:attr]];
    [self addNewlines:numberOfNewlines];
}

-(void)addNewlines:(int)numberOfNewlines
{
    static const char *newLines = "\n\n\n\n\n\n\n\n\n\n";
    
    if (!numberOfNewlines)
        return;
    
    [NSString stringWithFormat:@"%.*s", MAX(numberOfNewlines, 10), newLines];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
}

@end

#pragma mark -
#pragma mark sundown callbacks


static void
blockcode (struct buf *ob, const struct buf *input, const struct buf *lang, void *opaque)
{
    ParserContext *context = (__bridge ParserContext *)opaque;
    
    NSMutableParagraphStyle *m = [[NSMutableParagraphStyle alloc] init];
    m.headIndent = 10.0;
    m.firstLineHeadIndent = 10.0;
    NSDictionary *attrs = [NSDictionary dictionaryWithObject:m
                                                      forKey:NSParagraphStyleAttributeName];
    
    [context addTextFromBuffer:input attributes:attrs addNewlines:1];
    //[context addNewlines:1];
}

static void
blockquote (struct buf *ob, const struct buf *input, void *opaque)
{
    ParserContext *context = (__bridge ParserContext *)opaque;
    [context addTextFromBuffer:input];
    [context addNewlines:1];
}

static void
blockhtml (struct buf *ob, const struct buf *input, void *opaque)
{
    NSLog(@"BH: %s", input->data);
}

static void
list (struct buf *ob, const struct buf *text, int flags, void *opaque)
{
    
}
static void
listitem (struct buf *ob, const struct buf *text, int flags, void *opaque)
{
    
}

static void
header (struct buf *ob, const struct buf *input, int level, void *opaque)
{
    UIFont *font = [UIFont systemFontOfSize:(14 + (4 - level) * 4)];
    NSDictionary *attrs = [NSDictionary dictionaryWithObject:font
                                                      forKey:NSFontAttributeName];
    
    ParserContext *context = (__bridge ParserContext *)opaque;
    [context addNewlines:1];
    [context addTextFromBuffer:input attributes:attrs addNewlines:2];
}

static void
hrule (struct buf *ob, void *opaque)
{
    NSLog(@"FIXME HR");
}

static void
paragraph (struct buf *ob, const struct buf *input, void *opaque)
{
    ParserContext *context = (__bridge ParserContext *)opaque;
    [context addTextFromBuffer:input];
    [context addNewlines:1];
}

static void
table (struct buf *ob, const struct buf *header, const struct buf *body, void *opaque)
{
    
}

static void
table_row (struct buf *ob, const struct buf *text, void *opaque)
{
    
}

static void
table_cell (struct buf *ob, const struct buf *text, int flags, void *opaque)
{
    
}


/* *** */

static int
autolink (struct buf *ob, const struct buf *link, enum mkd_autolink type, void *opaque)
{
    
    return 0;
}

static int
codespan (struct buf *ob, const struct buf *text, void *opaque)
{
    return 0;
}

static int
double_emphasis (struct buf *ob, const struct buf *text, void *opaque)
{
    return 0;
}

static int
emphasis (struct buf *ob, const struct buf *text, void *opaque)
{
    return 0;
}

static int
image (struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *alt, void *opaque)
{
    return 0;
}

static int
md_link (struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *content, void *opaque)
{
    return 0;
}

static int raw_html_tag (struct buf *ob, const struct buf *tag, void *opaque)
{
    return 0;
}

static int
triple_emphasis (struct buf *ob, const struct buf *text, void *opaque)
{
    return 0;
}

static int
strikethrough (struct buf *ob, const struct buf *text, void *opaque)
{
    return 0;
}

static int
superscript (struct buf *ob, const struct buf *text, void *opaque)
{
    return 0;
}

static int
linebreak (struct buf *ob, void *opaque)
{
    ParserContext *context = (__bridge ParserContext *)opaque;
    [context addNewlines:1];
    return 1;
}


/* *** */
//static void
//normal_text (struct buf *ob, const struct buf *input, void *opaque)
//{
//    NSLog(@"T: %s", input->data);
//}


/* *** */
void
doc_header(struct buf *ob, void *opaque)
{
    NSLog(@"doc header");
}

void
doc_footer(struct buf *ob, void *opaque)
{
    NSLog(@"N: doc footer");
}

static const struct sd_callbacks md_callbacks = {
    blockcode,
    blockquote,
    blockhtml,
    header,
    hrule,
    list,
    listitem,
    paragraph,
    table,
    table_row,
    table_cell,
    
    autolink,
    codespan,
    double_emphasis,
    emphasis,
    image,
    linebreak,
    md_link,
    raw_html_tag,
    triple_emphasis,
    strikethrough,
    superscript,
    
    NULL,
    NULL,
    
    NULL,
    NULL,
};



/* **********************************************************************************   */
#pragma mark -
#pragma mark CKMarkdownParser


@implementation CKMarkdownParser

@synthesize attrHeaderL1;
@synthesize attrHeaderL2;
@synthesize attrHeaderL3;
@synthesize attrBlockCode;
@synthesize attrParagraph;

+ (NSAttributedString *)parseString:(NSString *)text
{
    struct buf *ob;
    struct sd_markdown *markdown;
    
    size_t len = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    const char *cstr = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    ob = bufnew(64); //FIXME do we need that?
    
    ParserContext *context = [[ParserContext alloc] initWithParser:nil];
    
    markdown = sd_markdown_new(0, 16, &md_callbacks, (__bridge void *)(context)); //(__bridge void *)(attrStr)
    sd_markdown_render(ob, (const uint8_t *) cstr, len, markdown);
	sd_markdown_free(markdown);
    bufrelease(ob);
    
    return context.text;
}


@end
