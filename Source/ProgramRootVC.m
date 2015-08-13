//
//  ProgramRootVC.m
//  INCF 13
//
//  Created by Christian Kellner on 15/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "ProgramRootVC.h"
#import "ProgramDayTVC.h"
#import "UIColor+ConferenceKit.h"
#import "AbstractVC.h"
#import "CKDataStore.h"

@interface ProgramRootVC () <ProgramDayDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayNext;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dayPrev;

@property (weak, nonatomic) IBOutlet UIView *container;

@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;

@property (strong, nonatomic) NSArray *dayController; //of type ProgramDayTVC
@property (nonatomic) NSInteger dayIndex;
@end

@implementation ProgramRootVC
@synthesize dayIndex = _dayIndex;

#pragma mark layout

- (void)addConstraintsForView:(UIView *)view leftOf:(UIView *)leftView
{
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.container
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0f
                                                               constant:0];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.container
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0f
                                                             constant:0];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.container
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0f
                                                                constant:0];
    NSLayoutConstraint *left = nil;
    if (leftView) {
        left = [NSLayoutConstraint constraintWithItem:view
                                            attribute:NSLayoutAttributeLeft
                                            relatedBy:NSLayoutRelationEqual
                                               toItem:leftView
                                            attribute:NSLayoutAttributeRight
                                           multiplier:1.0f
                                             constant:0];
        
        
    } else {
        left = [NSLayoutConstraint constraintWithItem:view
                                            attribute:NSLayoutAttributeLeft
                                            relatedBy:NSLayoutRelationEqual
                                               toItem:self.container
                                            attribute:NSLayoutAttributeLeft
                                           multiplier:1.0f
                                             constant:0];
        self.leftConstraint = left;
    }
    
    [self.container addConstraint:left];
    [self.container addConstraint:width];
    [self.container addConstraint:top];
    [self.container addConstraint:height];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
{
    self.dayNext.enabled = NO;
    self.dayPrev.enabled = NO;
    [self.view setNeedsUpdateConstraints];
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.leftConstraint.constant = -1.0f * self.view.frame.size.width * self.dayIndex;
    [self.container layoutIfNeeded];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //Bug in ios??
    for (ProgramDayTVC *pdvc in self.dayController) {
        CGSize contentSize = pdvc.tableView.contentSize;
        contentSize.width = pdvc.tableView.bounds.size.width;
        pdvc.tableView.contentSize = contentSize;
    }
    
    self.dayPrev.enabled = self.dayIndex != 0;
    self.dayNext.enabled = self.dayIndex != self.dayController.count - 1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.toolbar.tintColor = [UIColor ckColor];
    self.navigationController.toolbar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.delegate = self;
    self.container.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"Program" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:dataPath];
    id list= [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![list isKindOfClass:[NSArray class]]) {
        NSLog(@"Error parsing program file");
        return;
    }
    
    NSArray *days = (NSArray *) list;
    
    NSMutableArray *vcList = [[NSMutableArray alloc] initWithCapacity:days.count];
    
    UIView *lastView = nil;
    
    CKSchedule *schedule = [[CKDataStore defaultStore] schedule];
    
    for (CKDay *day in schedule.days) {
        ProgramDayTVC *pdvc = [[ProgramDayTVC alloc] initWithDay:day];
        
        pdvc.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.container addSubview:pdvc.view];
        [self addConstraintsForView:pdvc.view leftOf:lastView];
        lastView = pdvc.view;
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            pdvc.tableView.contentInset = UIEdgeInsetsMake(10, 0, 88, 0);
        }
        
        [vcList addObject:pdvc];
    }
    
    self.dayController = vcList;
    
    self.dayIndex = 0;
}


- (void) setDayIndex:(NSInteger)dayIndex
{
    self.dayPrev.enabled = dayIndex != 0;
    self.dayNext.enabled = dayIndex != self.dayController.count - 1;
    
    ProgramDayTVC *pdvc = self.dayController[dayIndex];
    self.dayLabel.title = [NSString stringWithFormat:@"%0.2d.%0.2d", pdvc.day.date.day, pdvc.day.date.month];
    
    _dayIndex = dayIndex;
}


- (IBAction)prevDay:(id)sender
{
    self.dayIndex--;
    self.leftConstraint.constant += self.view.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    

}

- (IBAction)nextDay:(id)sender
{
    self.dayIndex++;
    self.leftConstraint.constant -= self.view.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL hideNavigationBar = [viewController isKindOfClass:[ProgramRootVC class]];
    self.navigationController.navigationBarHidden = hideNavigationBar;
}

#pragma mark -
#pragma mark ProgramDayDelegate

-(void)programDay:(ProgramDayTVC *)programDay didSelectEvent:(NSDictionary *)event
{
    NSString *uuid = event[@"abstract"];
    
    if (!uuid) {
        //no uuid, nothing to do
        return;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Abstract"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
    request.predicate = predicate;
    
    CKDataStore *ds = [CKDataStore defaultStore];
    NSArray *result = [ds.managedObjectContext executeFetchRequest:request error:nil];
    
    if (result.count < 1) {
        //NSLog(@"Warning: Absrtact for frontid: %@ not found\n", frontid);
        return;
    }
    
    AbstractVC *abc = [self.storyboard instantiateViewControllerWithIdentifier:@"AbstractVC"];
    abc.abstract = [result lastObject];
    abc.showNavigator = NO;
    
    [self.navigationController pushViewController:abc animated:YES];
}

@end
