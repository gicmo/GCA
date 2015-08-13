//
//  ProgramDayTVC.m
//  NI2013
//
//  Created by Christian Kellner on 18/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "ProgramDayTVC.h"
#import "ProgramPointCell.h"

@interface ProgramDayTVC () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ProgramDayTVC

@synthesize delegate = _delegate;
@synthesize day = _day;

-(instancetype) initWithDay:(CKDay *)day {
    self = [super initWithNibName:@"ProgramDayTVC" bundle:nil];
    
    if (self) {
        _day = day;
    }
    
    return self;
}

+(ProgramDayTVC *)controllerForDay:(CKDay *)day
{
    ProgramDayTVC *pdvc = [[ProgramDayTVC alloc] initWithDay:day];
    return pdvc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *programCellNib = [UINib nibWithNibName:@"ProgramPointCell" bundle:nil];
    [self.tableView registerNib:programCellNib forCellReuseIdentifier:@"ProgramPointCell"];
    
    self.tableView.delegate = self;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.day.events.count;
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
    CKScheduleItem *item = self.day.events[indexPath.row];
    return [ProgramPointCell heightForEvent:item];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKScheduleItem *item = self.day.events[indexPath.row];
    ProgramPointCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramPointCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setEvent:item];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CKScheduleItem *item = self.day.events[indexPath.row];
    
    if ([item isKindOfClass:[CKEvent class]]) {
        //FIXME [self.delegate programDay:self didSelectEvent:event];
    }
}

@end
