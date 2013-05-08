//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "ProgramInfoVC.h"
#import "InfoView.h"
#import "GCAAppDelegate.h"
#import "UIColor+GCA.h"

@interface ProgramInfoVC ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) InfoView *infoView;

@end

@implementation ProgramInfoVC
@synthesize scrollView;
@synthesize infoView;
@synthesize info = _info;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    if (self.info) {
        [self.infoView resetFormat];
        
        self.scrollView.backgroundColor = [UIColor tmColor];
        
        NSData *data = [self.info dataUsingEncoding:NSUTF8StringEncoding];
        
        CGRect frame;
        frame = CGRectMake(10, 5, self.scrollView.frame.size.width - 20, 0);
        InfoView *iv = [[InfoView alloc] initWithFrame:frame];
        iv.backgroundColor = [UIColor tmColor];
        iv.fgColor = [UIColor whiteColor];
        
        iv.data = data;
        
        CGSize newFrame = CGSizeMake(self.scrollView.frame.size.width - 20, CGFLOAT_MAX);
        CGSize newSize = [iv sizeThatFits:newFrame];
        frame.origin.x = 10;
        frame.size = newSize;
        iv.frame = frame;
        [self.scrollView addSubview:iv];
        newSize.height += 20;
        self.scrollView.contentSize = newSize;
        self.infoView = infoView;
        
    }
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setInfoView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
