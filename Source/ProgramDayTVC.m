//
//  ProgramDayTVC.m
//  NI2013
//
//  Created by Christian Kellner on 18/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "ProgramDayTVC.h"
#import "ProgramPointCell.h"
#import "WorkshopCell.h"

@interface ProgramDayTVC () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ProgramDayTVC

@synthesize date;
@synthesize events = _events;
@synthesize delegate = _delegate;



+(ProgramDayTVC *)controllerForDay:(NSDate *)date withEvents:(NSArray *)events
{
    ProgramDayTVC *pdvc = [[ProgramDayTVC alloc] init];
    pdvc.date = date;
    pdvc.events = events;
    
    return pdvc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UINib *programCellNib = [UINib nibWithNibName:@"ProgramPointCell" bundle:nil];
    [self.tableView registerNib:programCellNib forCellReuseIdentifier:@"ProgramPointCell"];
    
    UINib *workshopCellNib = [UINib nibWithNibName:@"WorkshopCell" bundle:nil];
    [self.tableView registerNib:workshopCellNib forCellReuseIdentifier:@"WorkshopCell"];
    
}

- (void)setEvents:(NSArray *)events
{
    _events = events;
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.events.count;
}

//Header

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)index
{
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

//Cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *event = [self.events objectAtIndex:indexPath.row];
    NSString *eventType = event[@"type"];
    
    if ([eventType isEqualToString:@"workshop"]) {
        return [WorkshopCell heightForEvent:event];
    } else {
        return [ProgramPointCell heightForEvent:event];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<ProgramEventView> *cell = nil;
    NSDictionary *event = [self.events objectAtIndex:indexPath.row];
    NSString *eventType = event[@"type"];
   
    if (![eventType isEqualToString:@"workshop"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramPointCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"WorkshopCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setEvent:event];
    return cell;
}


@end
