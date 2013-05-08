//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "ProgramRootVC.h"
#import <CoreData/CoreData.h>
#import "GCAAppDelegate.h"
#import "ProgramListTVC.h"
#import "ProgramInfoVC.h"
#import "ProgramCell.h"

#import "Abstract.h"
#import "AbstractVC.h"

#import "UIColor+GCA.h"

@interface ProgramRootVC () <ProgramListDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayPrev;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayNext;

@property (weak, nonatomic) ProgramListTVC *programList;
@property (strong, nonatomic) NSArray *days; //of type ProgramListTVC
@property (nonatomic) NSInteger dayIndex;
@end

@implementation ProgramRootVC
@synthesize subView;
@synthesize dayLabel;
@synthesize dayPrev;
@synthesize dayNext;
@synthesize programList;
@synthesize days = _days;
@synthesize dayIndex = _dayIndex;

- (void) setDayIndex:(NSInteger)dayIndex
{
    ProgramListTVC *curPL = self.programList;
    ProgramListTVC *newPL = [self.days objectAtIndex:dayIndex];
    BOOL isInit = self.programList == nil;
    self.programList = newPL;
    
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    [dayDateFormatter setDateFormat:@"EEEE, dd.MM."];
    self.dayLabel.title = [dayDateFormatter stringFromDate:newPL.date];
    
    self.dayPrev.enabled = dayIndex != 0;
    self.dayNext.enabled = dayIndex != self.days.count - 1;
    
    if (isInit) {
        [self.subView addSubview:self.programList.view];
        self.programList.view.frame = self.subView.bounds;
        //NSLog(@"%f %f \n", self.programList.view.frame.size.height, self.subView.frame.size.height);
        return; // first assignment, we are done
    }
    
    // Animations
    if (_dayIndex == dayIndex)
        return;
    

    CGRect newFrame = curPL.view.frame;
    CGRect oldFrame = curPL.view.frame;
    
    if (dayIndex > _dayIndex) {
        //Forwards
        newFrame.origin.x += newFrame.size.width + 5;
        oldFrame.origin.x -= oldFrame.size.width;
    } else {
        //Backward
        newFrame.origin.x -= newFrame.size.width + 5;
        oldFrame.origin.x += oldFrame.size.width;
    }
    
    self.programList.view.frame = newFrame;
    [self.subView addSubview:newPL.view];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    newPL.view.frame = curPL.view.frame;
    curPL.view.frame = oldFrame;
    
    [UIView commitAnimations];
    _dayIndex = dayIndex;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIStoryboard *storyboard = self.storyboard;
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"Program" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:dataPath];
    id list= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![list isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSArray *days = (NSArray *) list;
    //NSLog(@"Number of days: %u \n", days.count);
    
    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    [dayDateFormatter setDateFormat:@"dd.MM.yyyy"];
    NSMutableArray *vcList = [[NSMutableArray alloc] initWithCapacity:days.count];
    
    for (NSDictionary *dayDict in days) {
        NSString *dateString = [dayDict objectForKey:@"date"];
        NSDate *date = [dayDateFormatter dateFromString:dateString];
        ProgramListTVC *plvc = [storyboard instantiateViewControllerWithIdentifier:@"ProgramList"];
        plvc.date = date;
        plvc.events = [dayDict objectForKey:@"events"];
        plvc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        plvc.delegate = self;
        [vcList addObject:plvc];
    }
    self.days = vcList;
    [self setDayIndex:0];
    
    //
    self.navigationController.toolbar.tintColor = [UIColor tmColor];
    self.navigationController.navigationBar.tintColor = [UIColor tmColor];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidUnload
{
    [self setSubView:nil];
    [self setDayLabel:nil];
    [self setDayPrev:nil];
    [self setDayNext:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)nextDay:(id)sender
{ 
    self.dayIndex += 1;
}

- (IBAction)prevDay:(id)sender {
    self.dayIndex -= 1;
}

#pragma - ProgramListDelegate

- (void)showAbstract:(NSString *)frontid
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Abstract"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"aid == %@", frontid];
    request.predicate = predicate;
    
    GCAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *result = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
    
    if (result.count < 1) {
        //NSLog(@"Warning: Absrtact for frontid: %@ not found\n", frontid);
        return;
    }
    
    AbstractVC *abc = [self.storyboard instantiateViewControllerWithIdentifier:@"AbstractVC"];
    abc.abstract = [result lastObject];
    abc.showNavigator = NO;
    
    [self.navigationController pushViewController:abc animated:YES];
}

-(void)showInfo:(NSString *)info
{
    ProgramInfoVC *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgramInfo"];
    ivc.info = info;
    [self.navigationController pushViewController:ivc animated:YES];
}

- (void) programList:(ProgramListTVC *)programList didSelectEvent:(NSDictionary *)event
{
    NSString *frontid = [event objectForKey:@"id"];
    NSString *info;
    if (frontid != nil) {
        [self showAbstract:frontid];
    } else if ((info = [event objectForKey:@"info"]) != nil) {
        [self showInfo:info];
    }
    
   
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL hideNavigationBar = [viewController isKindOfClass:[ProgramRootVC class]];
    self.navigationController.navigationBarHidden = hideNavigationBar;
}

@end
