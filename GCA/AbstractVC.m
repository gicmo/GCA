//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "AbstractVC.h"
#import "Author.h"
#import "Organization.h"
#import "Affiliation.h"

#import "Abstract+HTML.h"
#import "Abstract+Utils.h"
#import "AbstractView.h"

#import "UIColor+GCA.h"

@interface AbstractVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UISegmentedControl *abstractNavigator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starButton;

@property (strong, nonatomic, readonly) UIImage *starEmpty;
@property (strong, nonatomic, readonly) UIImage *starFilled;
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
    self.title = [abstract formatId:YES];
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
    
    self.navigationController.toolbarHidden = NO;
    
    self.navigationController.toolbar.tintColor = [UIColor tmColor];
    [self.abstractNavigator addTarget:self
                         action:@selector(navigateAbstract:)
               forControlEvents:UIControlEventValueChanged];
    
    [self.webview setScalesPageToFit:YES];
    [self renderAbstract];
}

- (void)viewDidUnload
{
    [self setWebview:nil];
    [self setAbstractNavigator:nil];
    [self setStarButton:nil];
    [self setStarButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)renderAbstract
{
    if (self.abstract)  {
        NSString *html = [self.abstract renderHTML];
        [self.webview loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
        [self updateStarButton];
    }
}

- (void)navigateAbstract:(id)sender
{
    UISegmentedControl *segment = sender;
    
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
        self.starButton.tintColor = [UIColor colorWithRed:11/255.0 green:57/255.0 blue:152/255.0 alpha:1.0];
    }
    
    self.starButton.image = img;

}

- (IBAction)toggleStar:(id)sender
{
    self.abstract.isFavorite = ! self.abstract.isFavorite;
    [self.delegate abstractChanged:self];
    [self updateStarButton];
}

@end
