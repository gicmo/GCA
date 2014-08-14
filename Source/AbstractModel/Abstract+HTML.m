//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "Abstract+HTML.h"
#import "Abstract+Utils.h"
#import "Author.h"
#import "Organization.h"
#import "Affiliation.h"
#import "Correspondence.h"

@implementation NSString(HTML)

- (NSString *) formatHTML
{
    NSString *tmp = [self stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    return [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
}

@end

@implementation Abstract (HTML)

- (NSString *)renderHTML
{
    NSMutableString *html = [[NSMutableString alloc] init];
    
    [html appendString:@"<html><head>"];
    [html appendString:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"Abstract.css\" />"];
    [html appendString:@"<meta name='viewport' content='initial-scale=1.0,maximum-scale=10.0'/>"];
    [html appendString:@"</head><body>"];
    [html appendFormat:@"<div id=\"aid\">%@</div>", [self formatId:YES]];
    [html appendFormat:@"<div id=\"topic\">%@</div>", self.topic];
    [html appendFormat:@"<div><h1 id=\"title\">%@</h2></div>", self.title];
    
    [html appendString:@"<div><h2 id=\"author\">"];
    for (Author *author in self.authors) {
        [html appendFormat:@"%@", author.name];
        
        [html appendFormat:@"<sup id=\"epithat\">"];
        NSUInteger count = 0;
        for (NSUInteger i = 0; i < self.affiliations.count; i++) {
            Affiliation *affiliation = [self.affiliations objectAtIndex:i];
            if ([affiliation.ofAuthors containsObject:author]) {
                [html appendFormat:@"%s%u", count != 0 ? ", " : "", i+1];
                count++;
            }
        }
        
        for (Correspondence *cor in self.correspondenceAt) {
            if (cor.ofAuthor == author)
                [html appendString:@"*"];
        }
        
        [html appendFormat:@"</sup><br/>"];
        
    }
    [html appendString:@"</h2></div><div id=\"affiliations\">"];
    [html appendFormat:@"<ol>"];
    
    for (NSUInteger i = 0; i < self.affiliations.count; i++) {
        Affiliation *affiliation = [self.affiliations objectAtIndex:i];
        Organization *org = affiliation.toOrganization;
        
        [html appendFormat:@"<li>"];
        
        if (org.section)
            [html appendFormat:@"%@, ", org.department];
        
        if (org.department)
            [html appendFormat:@"%@, ", org.department];
        
        [html appendFormat:@"%@, %@", org.name, org.country];
        [html appendFormat:@"</li>"];
    }
    
     [html appendFormat:@"</ol>"];
    for (Correspondence *cor in self.correspondenceAt) {
        [html appendFormat:@"</div><div id=\"correspondence\"><sup>*</sup> %@ ", cor.email];
    }
    [html appendString:@"</div><br/>"];
    
    [html appendFormat:@"<div><p id=\"abstract\">%@</p></div>", [self.text formatHTML]];
    
    if (self.acknoledgements && self.acknoledgements.length)
        [html appendFormat:@"<div class=\"appendix\"><h4>Acknowledgements</h4><p>%@</p></div>", [self.acknoledgements formatHTML]];
    
    if (self.references && self.references.length)
        [html appendFormat:@"<div class=\"appendix\"><p><h4>References</h4><p>%@</p></div>", [self.references formatHTML]];
    
    NSArray *legitFormats = @[ @"tiff", @"png", @"jpeg", @"pdf"];
    if (self.nfigures) {
        NSString *figID = [NSString stringWithFormat:@"%03d", self.figid];
        NSLog(@"figure path: %@", figID);
        
        __block NSString *fullpath = @"";
        
        [legitFormats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            fullpath = [NSString stringWithFormat:@"%@.%@", figID, obj];
            NSString *testPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fullpath];
            *stop = [[NSFileManager defaultManager] fileExistsAtPath:testPath];
        }];
        
        NSString *caption = self.caption;
        if ([caption hasPrefix:@"Figure 1"]) {
            caption = [caption substringFromIndex:8];
        }
        
        [html appendFormat:@"<div class=\"figure\"><img src=\"%@\" /><p>Figure 1:%@<p></div><br/>", fullpath, caption];
    }
    
    [html appendFormat:@"<div>doi: <a href=\"http://dx.doi.org/%@\">%@</a></div><br/>", self.doi, self.doi];
    [html appendString:@"</body></html>"];
    
    return html;
}


@end
