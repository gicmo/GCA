//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "NSAttributedString+GSX.h"
#import <CoreText/CoreText.h>

@interface GSXParser : NSObject <NSXMLParserDelegate>

-(id) initWithData:(NSData *)gsxData andFormat:(NSDictionary *)format;
- (NSAttributedString *) parseData;

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSMutableAttributedString *str;
@property (nonatomic, strong) NSDictionary *format;

@end

@implementation GSXParser

@synthesize data = _data;
@synthesize str = _str;
@synthesize format = _format;

-(id) initWithData:(NSData *)gsxData andFormat:(NSDictionary *)format
{
    self = [super init];
    if (self) {
        self.data = gsxData;
        self.format = format;
    }
    return self;
}

-(NSAttributedString *)parseData
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.data];
    [parser setShouldProcessNamespaces:NO];
    parser.delegate = self;
    
    BOOL res = [parser parse];
    return res ? [self.str copy] : nil;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"start: %@\n", elementName);
    
    if ([elementName isEqualToString:@"gsx"]) {
        self.str = [[NSMutableAttributedString alloc] initWithString:@"" attributes:nil];
    } else if ([elementName isEqualToString:@"section"]) {
        NSString *caption = [NSString stringWithFormat:@"\n%@\n", [attributeDict objectForKey:@"name" ]];
        NSDictionary *attr = [self.format objectForKey:@"section"];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:caption attributes:attr];
        [self.str appendAttributedString:attrString];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //NSLog(@"end: %@\n", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"chars: %@\n", string);
    NSDictionary *attr = [self.format objectForKey:@"text"];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attr];
    [self.str appendAttributedString:attrString];
}


@end

@implementation NSAttributedString (GSX)

-(id) initWithGSX:(NSData *)gsxData andFormat:(NSDictionary *)format
{
    GSXParser *parser = [[GSXParser alloc] initWithData:gsxData andFormat:format];
    NSAttributedString *attributedString = [parser parseData];
    self = [self initWithAttributedString:attributedString];
    return self;
}

@end
