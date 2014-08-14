//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "AbstractVC.h"
#import "Author.h"
#import "Organization.h"
#import "Affiliation.h"

#import "Abstract+HTML.h"
#import "Abstract+Utils.h"

#import "UIColor+ConferenceKit.h"

@interface AbstractVC () <UISplitViewControllerDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UISegmentedControl *abstractNavigator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbariPad;

@property (strong, nonatomic, readonly) UIImage *starEmpty;
@property (strong, nonatomic, readonly) UIImage *starFilled;


@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end


@implementation AbstractVC
@synthesize starButton = _starButton;
@synthesize webview = _webview;
@synthesize abstractNavigator = _abstractNavigator;
@synthesize abstract = _abstract;

@synthesize starEmpty = _starEmpty;
@synthesize starFilled = _starFilled;

- (UIImage *)starEmpty
{
    if (!_starEmpty) {
        _starEmpty = [UIImage imageNamed:@"00-StarWhite"];
    }
    return _starEmpty;
}

- (UIImage *)starFilled
{
    if (!_starFilled) {
        _starFilled = [UIImage imageNamed:@"00-StarWhiteFilled"];
    }
    return _starFilled;
}


- (void) setAbstract:(Abstract *)abstract
{
    _abstract = abstract;
    if (_abstract) {
        self.title = [abstract formatId:YES];
    } else {
        self.title = @"";
    }
    
    self.abstractNavigator.enabled = _abstract != nil;
    self.starButton.enabled = _abstract != nil;;
    
    [self renderAbstract];
}

-(void)setShowNavigator:(BOOL)showNavigator
{
    self.abstractNavigator.hidden = !showNavigator;
}

-(BOOL)showNavigator
{
    return ! self.abstractNavigator.hidden;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.splitViewController) {
        self.splitViewController.delegate = self;
        self.toolbariPad.tintColor = [UIColor ckColor];
    }
    
    self.navigationController.toolbarHidden = YES;
    
    self.navigationController.toolbar.tintColor = [UIColor ckColor];
    self.navigationController.toolbar.opaque = NO;
    [self.abstractNavigator addTarget:self
                         action:@selector(navigateAbstract:)
               forControlEvents:UIControlEventValueChanged];
    
    [self.webview setScalesPageToFit:YES];
    [self renderAbstract];
    
    self.webview.delegate = self;

    if (self.toolbar) {
        self.toolbar.tintColor = [UIColor ckColor];
    }
    
}

- (void)viewDidUnload
{
    [self setWebview:nil];
    [self setAbstractNavigator:nil];
    [self setStarButton:nil];
    [self setStarButton:nil];
    [super viewDidUnload];
}

- (void)renderAbstract
{
    NSString *html;
    if (! self.abstract)  {
        html = @"<html><body></body></html>";
    } else {
        html = [self.abstract renderHTML];
    }
    
    [self.webview loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
    [self updateStarButton];
}

- (void)navigateAbstract:(id)sender
{
    UISegmentedControl *segment = sender;
    
    if (!self.abstract) {
        return;
    }
    
    if ([segment selectedSegmentIndex] == 0) {
       [self.delegate prevAbstract:self];
    } else if ([segment selectedSegmentIndex] == 1) {
        [self.delegate abstractVC:self nextAbstract:self.abstract];
    }
}

- (void)updateStarButton
{
    UIImage *img;
    if (self.abstract.isFavorite) {
        img = self.starFilled;
        self.starButton.tintColor = [UIColor colorWithRed:42/255.0 green:93/255.0 blue:186/255.0 alpha:1.0];
    } else {
        img = self.starEmpty;
        self.starButton.tintColor = [UIColor ckColor];
    }
    
    self.starButton.image = img;

}

- (IBAction)toggleStar:(id)sender
{
    self.abstract.isFavorite = ! self.abstract.isFavorite;
    [self.delegate abstractChanged:self];
    [self updateStarButton];
}

#pragma mark SplitViewControllerDelegate

-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSArray *items = self.toolbariPad.items;
    NSMutableArray *mutabor = [NSMutableArray arrayWithArray:items];
    [mutabor removeObject:barButtonItem];
    [self.toolbariPad setItems:mutabor animated:YES];
}

-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc
{
    [barButtonItem setTitle:@"Abstracts"];
    NSArray *items = self.toolbariPad.items;
    NSMutableArray *mutabor = [NSMutableArray arrayWithArray:items];
    [mutabor insertObject:barButtonItem atIndex:0];
    [self.toolbariPad setItems:mutabor animated:YES];
}

#pragma mark webview

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSLog(@"should start loading.. %@", [url absoluteString]);
    
    if ([[url absoluteString] hasPrefix:@"file:///"]) {
        NSLog(@"XXXX");
        return YES;
    }
    
    [[UIApplication sharedApplication] openURL:url];

    return NO;
}

@end
