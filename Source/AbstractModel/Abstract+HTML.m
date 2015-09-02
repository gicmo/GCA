//Copyright (c) 2012-2015, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2015, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)


#import "Abstract+HTML.h"
#import "Abstract+Format.h"
#import "Author.h"
#import "Author+Format.h"
#import "Organization.h"
#import "Organization+Format.h"
#import "Affiliation.h"
#import "Correspondence.h"
#import "Reference.h"
#import "Figure.h"

@implementation NSString(HTML)

- (NSString *) formatHTML
{
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
}

@end

@implementation Abstract (HTML)

- (NSString *)renderHTML
{
    NSMutableString *html = [[NSMutableString alloc] init];

    [html appendString:@"<html><head>"];
    [html appendString:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"Abstract.css\" />"];
    [html appendString:@"<meta name='viewport' content='initial-scale=1.0,maximum-scale=10.0'/>"];

    if ([self.text containsString:@"$"]) {

        [html appendString:@""
        "<script type='text/x-mathjax-config'>"
        "MathJax.Hub.Config({ showMathMenu: false,"
        "jax: ['input/TeX','output/HTML-CSS'],"
        "tex2jax: {inlineMath: [ ['$','$']], displayMath: [ ['$$','$$'] ], processEscapes: true},"
        "extensions: ['tex2jax.js'],"
        "'HTML-CSS': {"
        "availableFonts: ['TeX'],"
        "preferredFont: 'TeX'},"
        "TeX: { extensions: ['AMSmath.js', 'AMSsymbols.js', 'noErrors.js', 'noUndefined.js'] }});"
        "</script>"];

        [html appendString:@"<script type='text/javascript' src='MathJax/MathJax.js'></script>"];
    }

    [html appendString:@"</head><body>"];
    [html appendFormat:@"<div id=\"aid\">%@</div>", [self formatId:YES]];
    [html appendFormat:@"<div id=\"topic\">%@</div>", self.topic ?: @"" ];
    [html appendFormat:@"<div><h1 id=\"title\">%@</h2></div>", self.title];

    [html appendString:@"<div><h2 id=\"author\">"];
    for (Author *author in self.authors) {
        [html appendFormat:@"%@", [author fullName]];

        [html appendFormat:@"<sup id=\"epithat\">"];
        NSUInteger count = 0;
        for (short i = 0; i < self.affiliations.count; i++) {
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

    for (Affiliation *affiliation in self.affiliations) {
        Organization *org = affiliation.toOrganization;
        [html appendFormat:@"<li>%@</li>", [org mkString]];
    }

    [html appendFormat:@"</ol>"];
    for (Correspondence *cor in self.correspondenceAt) {
        [html appendFormat:@"</div><div id=\"correspondence\"><sup>*</sup> %@ ", cor.email];
    }
    [html appendString:@"</div><br/>"];

    [html appendFormat:@"<div><p id=\"abstract\">%@</p></div>", [self.text formatHTML]];

    if (self.altid) {
        [html appendFormat:@"<div>See also poster: %@</div>",
         [self formatId:YES]];
    }
    
    if (self.acknoledgements && self.acknoledgements.length)
        [html appendFormat:@"<div class=\"appendix\"><h4>Acknowledgements</h4><p>%@</p></div>", [self.acknoledgements formatHTML]];

    if (self.references && self.references.count) {
        [html appendFormat:@"<div class=\"appendix\"><p><h4>References</h4><ol>"];
        for (Reference *ref in self.references) {

            [html appendString:@"<li>"];
            [html appendFormat:@"%@", ref.text];
            if (ref.link) {
                [html appendFormat:@"<a href=\"%@\"> %@</a>",
                 ref.link, ref.text ? @"Link" : ref.link];
            }
            if (ref.doi) {
                [html appendFormat:@"<a href=\"http://dx.doi.org/%@\"> %@</a>", ref.doi, ref.doi];
            }
            [html appendString:@"</li>"];

        }
        [html appendString:@"</ol></div>"];
    }

    NSArray *legitFormats = @[ @"tiff", @"png", @"jpeg", @"pdf", @"" ];

    for (short i = 0; i < self.figures.count; i++) {
        Figure *figure = self.figures[i];

        __block NSString *fullpath = nil;
        __block BOOL have_thumbnail = false;

        [legitFormats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            fullpath = [NSString stringWithFormat:@"%@.%@", figure.uuid, obj];
            NSString *testPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fullpath];
            *stop = have_thumbnail = [[NSFileManager defaultManager] fileExistsAtPath:testPath];
        }];

        if (!have_thumbnail) {
            fullpath = figure.url;
        }

        [html appendString:@"<div class=\"figure\">"];
        [html appendFormat:@"<a href=\"%@\"><img src=\"%@\" /></a><p>Figure %d: %@<p>",
         figure.url, fullpath, i+1, figure.caption];
        [html appendFormat:@"</div><br/>"];
    }

    if (self.doi) {
        [html appendFormat:@"<div>doi: <a href=\"http://dx.doi.org/%@\">%@</a></div><br/>", self.doi, self.doi];
    }
    
    [html appendString:@"</body></html>"];

    
    return html;
}

@end
