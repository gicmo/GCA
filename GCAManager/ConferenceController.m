//
//  ConferenceController.m
//  GCA
//
//  Created by Christian Kellner on 10/08/15.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import "ConferenceController.h"

#import "JSONImporter.h"
#import "Conference.h"

@interface ConferenceController () <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSButton *selectConfButton;
@property (nonatomic, strong) NSArray *conferences;
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation ConferenceController

- (void) setSelectedConference:(Conference *)selectedConference
{
    _selectedConference = selectedConference;
    self.selectConfButton.enabled = _selectedConference != NULL;
}


- (void)windowDidLoad {
    [super windowDidLoad];

}

- (IBAction)selectConference:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}
- (IBAction)letsCancle:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

- (void)loadConferenceFromJson:(NSURL *)location {
    NSManagedObjectContext *ctx = [[NSApp delegate] managedObjectContext];

    NSData *data = [[NSData alloc] initWithContentsOfURL:location];
    JSONImporter *imporer = [[JSONImporter alloc] initWithContext:ctx];

    BOOL didImport = [imporer importConference:data];

    if (didImport) {
        [self loadConferences];
        [self.tableView reloadData];
    }

}

- (IBAction)importConference:(id)sender {
    NSOpenPanel *chooser = [NSOpenPanel openPanel];
    chooser.title = @"Please select stylesheet";

    NSArray *filetypes = [NSArray arrayWithObjects:@"json", nil];
    chooser.allowedFileTypes = filetypes;

    chooser.canChooseFiles = YES;
    chooser.canChooseDirectories = NO;
    chooser.allowsMultipleSelection = NO;

    [chooser beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [self loadConferenceFromJson:chooser.URL];
        }
    }];
}

- (void)loadConferences {
    NSManagedObjectContext *ctx = [[NSApp delegate] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Conference"
                                              inManagedObjectContext:ctx];

    [request setEntity:entity];
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"aid" ascending:YES];
    //NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    //request.sortDescriptors = sortDescriptors;

    self.conferences = [ctx executeFetchRequest:request error:nil];
}

#pragma mark TableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return self.conferences.count;
}

- (id )tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    Conference *c = [self.conferences objectAtIndex:rowIndex];
    NSString *s =  [c valueForKey:aTableColumn.identifier];
    return [s copy];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger row = self.tableView.selectedRow;
    if (row < 0) {
        self.selectedConference = NULL;
    } else {
        self.selectedConference = self.conferences[row];
    }
}

@end
