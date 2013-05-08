//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "ProgramListTVC.h"
#import "ProgramCell.h"

#import "GCAAppDelegate.h"
#import "Abstract.h"
#import "AbstractVC.h"

#import <CoreData/CoreData.h>
#import "UIColor+GCA.h"

@interface ProgramListTVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ProgramListTVC
@synthesize tableView;
@synthesize date;
@synthesize events = _events;
@synthesize delegate = _delegate;

- (void)setEvents:(NSArray *)events
{
    _events = events;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.events.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *event = [self.events objectAtIndex:section];
    
    CGFloat width = self.tableView.contentSize.width;
    
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, width, 44.0)];
    
    UIColor *bgColor = [UIColor colorWithRed:0.72 green:0.84 blue:0.95 alpha:0.98];
    if ([[event objectForKey:@"type"] isEqual:@"food"])
        bgColor = [UIColor colorWithRed:0.95 green:0.97 blue:0.99 alpha:1.0];
	customView.backgroundColor = bgColor;
    
    CGFloat fontSize = 13;
    if ([[event objectForKey:@"type"] isEqual:@"food"])
        fontSize = 11;
    
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:fontSize];
	headerLabel.frame = CGRectMake(5.0, 0.0, width, 44.0);
   
    NSString *timeStr = @"       ";
    NSArray *subEvents = [event objectForKey:@"events"];
    if (subEvents.count < 2) {
        timeStr = [event objectForKey:@"time"];
    }
    
    NSString *title = [NSString stringWithFormat:@"%@  %@",
                       timeStr,
                       [event objectForKey:@"title"]];
    
	headerLabel.text = title;
	[customView addSubview:headerLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43.0, width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
    [customView addSubview:lineView];
    
    
	return customView;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *event = [self.events objectAtIndex:section];
    
    NSArray *subEvents = [event objectForKey:@"events"];

    if (subEvents == nil)
        return 0;
    
    return subEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProgramCell";
    ProgramCell *cell =  [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *main = [self.events objectAtIndex:indexPath.section];
    NSArray *events = [main objectForKey:@"events"];
    NSDictionary *event = [events objectAtIndex:indexPath.row];
    
    [cell setEvent:event];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *main = [self.events objectAtIndex:indexPath.section];
    NSArray *events = [main objectForKey:@"events"];
    NSDictionary *event = [events objectAtIndex:indexPath.row];
    BOOL isTalk = [event objectForKey:@"person"] != nil;
    
    if (isTalk) {
        return 62.0;
    }
    
    return 47;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *main = [self.events objectAtIndex:indexPath.section];
    NSArray *events = [main objectForKey:@"events"];
    NSDictionary *event = [events objectAtIndex:indexPath.row];
    
    [self.delegate programList:self didSelectEvent:event];
}


@end
