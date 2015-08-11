//
//  AppDelegate.m
//  AbstractManager
//
// Copyright (c) 2012 Christian Kellner <kellner@bio.lmu.de>.
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "AppDelegate.h"

#import "Abstract.h"
#import "Abstract+HTML.h"
#import "Author.h"
#import "Author+Format.h"
#import "Affiliation.h"
#import "AbstractGroup.h"
#import "JSONImporter.h"
#import "ConferenceController.h"
#import "Group.h"

#import <WebKit/WebKit.h>


#define PT_REORDER @"PasteBoardTypeReorder"

@interface AppDelegate ()  <NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;


@property (weak) IBOutlet NSOutlineView *abstractOutline;

@property (weak) IBOutlet WebView *abstractView;
@property (strong, nonatomic) NSString *latexStylesheet;
@property (strong, nonatomic) NSString *htmlStylesheet;

@property (weak) IBOutlet NSWindow *abstractsWindow;

@property (strong, nonatomic) ConferenceController *conferenceSheet;

@property (strong, nonatomic) Conference *conference;
@end

@implementation AppDelegate
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize abstractOutline = _abstractOutline;
@synthesize latexStylesheet = _latexStylesheet;
@synthesize htmlStylesheet = _htmlStylesheet;

- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"org.g-node.AbstractManager"];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Abstracts" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![[properties objectForKey:NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"G-Node" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSDictionary *ps_opts = @{NSSQLitePragmasOption: @{@"journal_mode":@"DELETE"}};
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Abstracts.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:ps_opts error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"G-Node" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

# pragma mark - NSWindowDelegate
// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSManagedObjectContext *context = self.managedObjectContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conference"];
    NSArray *result = [context executeFetchRequest:request error:nil];

    if (result.count > 0) {
        self.conference = result[0];
    }

    self.abstractOutline.delegate = self;
    self.abstractOutline.dataSource = self;
    
    [self.abstractOutline registerForDraggedTypes:[NSArray arrayWithObject:PT_REORDER]];
    [self.abstractOutline setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.abstractOutline setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}


#pragma mark - menu


- (IBAction)showConferencesSheet:(id)sender {

    self.conferenceSheet = [[ConferenceController alloc] initWithWindowNibName:@"ConferenceController"];

    [self.window beginSheet:self.conferenceSheet.window completionHandler:^(NSModalResponse returnCode) {
        NSLog(@"Foo!!");

        if (returnCode == NSModalResponseOK) {
            NSLog(@"%@", self.conferenceSheet.selectedConference.name);
            self.conference = self.conferenceSheet.selectedConference;
            [self.abstractOutline reloadData];
        }

        self.conferenceSheet = NULL;
    }];

}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}



- (IBAction)importData:(id)sender
{
    if (self.conference == NULL) {

        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Conference needed!"];
        [alert setInformativeText:@"Currently there is no conference selected!"];
        [alert setAlertStyle:NSWarningAlertStyle];

        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            //NOOP

        }];

        return;
    }

    NSOpenPanel* importDialog = [NSOpenPanel openPanel];
    importDialog.canChooseFiles = YES;
    importDialog.canChooseDirectories = NO;
    importDialog.allowsMultipleSelection = NO;
    
    [importDialog beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSData *data = [[NSData alloc] initWithContentsOfURL:importDialog.URL];
            
            JSONImporter *imporer = [[JSONImporter alloc] initWithContext:self.managedObjectContext];
            [imporer importAbstracts:data intoConference:self.conference];

            [self.abstractOutline reloadData];
        }
    }];   
}


- (NSArray*)abstractsForGroup:(Group *)group {
    NSManagedObjectContext *context = self.managedObjectContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Abstract"];
    NSPredicate *pd_conf = [NSPredicate predicateWithFormat:@"conference == %@", self.conference];

    int32_t start = group.prefix << 16;
    int32_t end = (group.prefix + 1) << 16;

    NSLog(@"start, end: %d, %d", start, end);

    NSPredicate *pd_aid = [NSPredicate predicateWithFormat:@"aid between {%d, %d}", start, end];
    NSCompoundPredicate *all = [NSCompoundPredicate andPredicateWithSubpredicates:@[pd_conf, pd_aid]];

    request.predicate = all;
    NSArray *result = [context executeFetchRequest:request error:nil];

    return result;
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return self.conference.abstracts.count;
}


#pragma - NSOutlineViewDataSource
- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{

    NSInteger nchildren = 0;
    if (item == nil)
        nchildren = self.conference.groups.count;
    else if ([item isKindOfClass:[Group class]]) {
        Group *group = item;
        nchildren = [self abstractsForGroup:group].count;
    }
    
    NSLog(@"- numberofChildren: %ld", nchildren);
    return nchildren;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return [self.conference.groups objectAtIndex:index];
    } else if ([item isKindOfClass:[Group class]]) {
        Group *group = item;
        NSArray *abstracts = [self abstractsForGroup:group];
        return [abstracts objectAtIndex:index];
    }
    
    return nil;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[Group class]]) {
        return YES;
    }
    
    return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSString *text = nil;
    if ([item isKindOfClass:[Group class]]) {
        Group *group = item;

        if ([tableColumn.identifier isEqualToString:@"author"]) {
            text = group.name;
        } else if ([tableColumn.identifier isEqualToString:@"title"])  {
            NSUInteger nums = [self abstractsForGroup:group].count;
            text = [NSString stringWithFormat:@"%ld", nums];
        } else  {
            text = @"";
        }
    } else if ([item isKindOfClass:[Abstract class]]) {
        Abstract *abstract = item;
        if ([tableColumn.identifier isEqualToString:@"author"]) {
            Author *author = [abstract.authors objectAtIndex:0];
            text = [author formatName];
        } else if ([tableColumn.identifier isEqualToString:@"title"]) {
            text = abstract.title;
        } else if ([tableColumn.identifier isEqualToString:@"topic"]) {
            text = abstract.topic;
        } else if ([tableColumn.identifier isEqualToString:@"nfigures"]) {
            text = [NSString stringWithFormat:@"%lu", (unsigned long)abstract.figures.count];
        }
    }
    return text;
}


- (void) outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [self.abstractOutline selectedRow];
    id item = [self.abstractOutline itemAtRow:row];
    
    if ([item isKindOfClass:[Abstract class]]) {
        Abstract *abstract = item;
        NSString *html = [abstract renderHTML];
        NSURL *base = [NSURL URLWithString:@"http://"];
        [self.abstractView.mainFrame loadHTMLString:html baseURL:base];
    }
    
}

@end
