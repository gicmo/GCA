//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "InfoVC.h"
#import "InfoView.h"
#import "NSAttributedString+GSX.h"
#import "UIColor+GCA.h"
#import <CoreText/CoreText.h>

@interface InfoVC ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) NSData *infoData;
@property (weak, nonatomic) IBOutlet UIView *aboutView;
@end

@implementation InfoVC
@synthesize aboutView;
@synthesize scrollView;
@synthesize coverImageView;
@synthesize headerLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadInfoData];
    CGRect  frame;
    CGFloat offset;
    
    self.scrollView.backgroundColor = [UIColor tmColor];
    frame = self.headerLabel.frame;
    frame.origin.y = self.coverImageView.frame.size.height + 10;
    self.headerLabel.frame = frame;
    
    offset = frame.origin.y + frame.size.height - 15;
    
    frame = CGRectMake(10, offset, self.coverImageView.frame.size.width - 20, 0);
    InfoView *iv = [[InfoView alloc] initWithFrame:frame];
    iv.backgroundColor = self.scrollView.backgroundColor;
    iv.data = self.infoData;
    iv.fgColor = [UIColor whiteColor];
    
    CGSize newFrame = CGSizeMake(self.coverImageView.frame.size.width - 20, CGFLOAT_MAX);
    CGSize newSize = [iv sizeThatFits:newFrame];
    frame.size = newSize;
    iv.frame = frame;
    
    [self.scrollView addSubview:iv];
    [self.scrollView bringSubviewToFront:headerLabel];

    offset = frame.origin.y + frame.size.height + 20;
    frame = self.aboutView.frame;
    frame.origin.y = offset;
    self.aboutView.frame = frame;
    
    frame.size.height = frame.origin.y + frame.size.height - (210 + 25);
    self.scrollView.contentSize = frame.size;
    
    frame.size.height += 500;
    self.aboutView.frame = frame;
    
    //begin animation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    frame = self.coverImageView.frame;
    frame.origin.y -= 210;
    self.coverImageView.frame = frame;
    
    frame = self.headerLabel.frame;
    frame.origin.y -= 210;
    self.headerLabel.frame = frame;
    
    frame = iv.frame;
    frame.origin.y -= 210;
    iv.frame = frame;
    
    frame = self.aboutView.frame;
    frame.origin.y -= 210;
    self.aboutView.frame = frame;

    self.headerLabel.alpha = 1.0;
    [UIView commitAnimations];
    
}


- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setCoverImageView:nil];
    [self setHeaderLabel:nil];
    [self setAboutView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadInfoData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Information" ofType:@"gsx"];
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.infoData = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
}

@end
