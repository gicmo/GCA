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

#import <WebKit/WebKit.h>


#define PT_REORDER @"PasteBoardTypeReorder"

@interface AppDelegate ()  <NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;


@property (weak) IBOutlet NSOutlineView *abstractOutline;

@property (weak) IBOutlet WebView *abstractView;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) NSString *latexStylesheet;
@property (strong, nonatomic) NSString *htmlStylesheet;
@property (strong, nonatomic) NSString *groupsFile;

@property (weak) IBOutlet NSWindow *abstractsWindow;

@property (strong, nonatomic) ConferenceController *conferenceSheet;

@end

@implementation AppDelegate
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize abstractOutline = _abstractOutline;
@synthesize latexStylesheet = _latexStylesheet;
@synthesize htmlStylesheet = _htmlStylesheet;
@synthesize groupsFile = _groupsFile;

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


- (NSArray *) loadGroups
{
    NSData *data = [NSData dataWithContentsOfFile:self.groupsFile];
    
    if (!data) {
        return nil;
    }
    
    id list = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![list isKindOfClass:[NSArray class]]) {
        NSLog(@"NOT A ARRAY!\n");
        return nil;
    }
    
    return (NSArray *) list;
}

- (BOOL) loadGroupsAndData
{
    NSArray *g = (NSArray *) [self loadGroups];
    NSUInteger count = g.count + 1;
    NSMutableArray *roots = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < g.count; i++) {
        uint8 uid = (uint8) i + 1;
        NSString *name = [g objectAtIndex:i];
        [roots addObject:[AbstractGroup groupWithUID:uid andName:name]];
    }
    
    [roots addObject:[AbstractGroup groupWithUID:0 andName:@"Unsorted"]];
    
    self.groups = roots;
    [self loadDataFromStore];
    
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self loadGroupsAndData];
   
    self.abstractOutline.delegate = self;
    self.abstractOutline.dataSource = self;
    
    [self.abstractOutline registerForDraggedTypes:[NSArray arrayWithObject:PT_REORDER]];
    [self.abstractOutline setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.abstractOutline setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}


- (NSString *) groupsFile
{
    if (_groupsFile == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _groupsFile = [defaults stringForKey:@"groups_file"];
    }
    
    return _groupsFile;
}

- (void) setGroupsFile:(NSString *)groupsFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:groupsFile forKey:@"groups_file"];
    NSLog(@"Setting groups_file\n");
    _groupsFile = groupsFile;
    
    if (groupsFile) {
        [self loadDataFromStore];
        [self.abstractOutline reloadData];
    }
    
}


#pragma mark - menu


- (IBAction)showConferencesSheet:(id)sender {

    self.conferenceSheet = [[ConferenceController alloc] initWithWindowNibName:@"ConferenceController"];

    [self.window beginSheet:self.conferenceSheet.window completionHandler:^(NSModalResponse returnCode) {
        NSLog(@"Foo!!");

        if (returnCode == NSModalResponseOK) {
            NSLog(@"%@", self.conferenceSheet.selectedConference.name);
        }

        self.conferenceSheet = NULL;
    }];

}


- (IBAction)menuSetGroupsJSON:(id)sender {
    NSOpenPanel *chooser = [NSOpenPanel openPanel];
    chooser.title = @"Please select stylesheet";
    
    NSArray *filetypes = [NSArray arrayWithObjects:@"json", nil];
    chooser.allowedFileTypes = filetypes;
    
    chooser.canChooseFiles = YES;
    chooser.canChooseDirectories = NO;
    chooser.allowsMultipleSelection = NO;
    
    [chooser beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            self.groupsFile = chooser.URL.path;
        }
    }];
}

- (IBAction)deleteAbstract:(id)sender
{
    NSInteger row = [self.abstractOutline selectedRow];
    id item = [self.abstractOutline itemAtRow:row];
    
    if (! [item isKindOfClass:[Abstract class]]) {
        return;
    }

    Abstract *abstract = item;
    [self removeAbstract:abstract.aid];
    [self.managedObjectContext deleteObject:abstract];
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
    NSOpenPanel* importDialog = [NSOpenPanel openPanel];
    importDialog.canChooseFiles = YES;
    importDialog.canChooseDirectories = NO;
    importDialog.allowsMultipleSelection = NO;
    
    [importDialog beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSData *data = [[NSData alloc] initWithContentsOfURL:importDialog.URL];
            
            JSONImporter *imporer = [[JSONImporter alloc] initWithContext:self.managedObjectContext];
            [imporer importAbstracts:data intoGroups:self.groups];
            
            [self loadDataFromStore];
            [self.abstractOutline reloadData];
        }
    }];   
}

- (void)loadDataFromStore
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Abstract"
                                              inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"aid" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    request.sortDescriptors = sortDescriptors;
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    NSLog(@"results.count: %lu\n", results.count);
    self.abstracts = results;
    
    for (AbstractGroup *group in self.groups) {
        [group.abstracts removeAllObjects];
    }
    
    for (Abstract *abstract in self.abstracts) {
        int32_t aid = abstract.aid;
        NSUInteger groupIndex = (aid & 0xFFFF0000) >> 16;
        NSLog(@"\tgroup index: %ld <- %d", groupIndex, ((aid & 0xFFFF0000) >> 16));
        AbstractGroup *group = [self.groups objectAtIndex:groupIndex];
        [group.abstracts addObject:abstract];//insertObject:abstract atIndex:abstractIndex];
    }
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    
    return self.abstracts.count;
}


#pragma - NSOutlineViewDataSource
- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{

    NSInteger nchildren = 0;
    if (item == nil)
        nchildren = self.groups.count;
    else if ([item isKindOfClass:[AbstractGroup class]]) {
        AbstractGroup *group = item;
        nchildren = group.abstracts.count;
    }
    
    NSLog(@"- numberofChildren: %ld", nchildren);
    return nchildren;
}

- (id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return [self.groups objectAtIndex:index];
    } else if ([item isKindOfClass:[AbstractGroup class]]) {
        AbstractGroup *group = item;
        return [group.abstracts objectAtIndex:index];
    }
    
    return nil;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[AbstractGroup class]]) {
        return YES;
    }
    
    return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSString *text = nil;
    if ([item isKindOfClass:[AbstractGroup class]]) {
        AbstractGroup *group = item;

        if ([tableColumn.identifier isEqualToString:@"author"]) {
            text = group.name;
        } else if ([tableColumn.identifier isEqualToString:@"title"])  {
            text = [NSString stringWithFormat:@"%ld", group.abstracts.count];
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

#pragma - Drag & Drop

- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView
                pasteboardWriterForItem:(id)item
{
    if ([item isKindOfClass:[Abstract class]]) {
        Abstract *abstract = item;
        return abstract.title;
    }
    return nil;
}

- (void) outlineView:(NSOutlineView *)outlineView
     draggingSession:(NSDraggingSession *)session
    willBeginAtPoint:(NSPoint)screenPoint
            forItems:(NSArray *)draggedItems
{
    int32_t aid = [[draggedItems lastObject] aid];
    NSData *data = [NSData dataWithBytes:&aid length:sizeof(aid)];
    [session.draggingPasteboard setData:data forType:PT_REORDER];
}

- (void) outlineView:(NSOutlineView *)outlineView
     draggingSession:(NSDraggingSession *)session
        endedAtPoint:(NSPoint)screenPoint
           operation:(NSDragOperation)operation
{
    NSLog(@"Drag ended\n");
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                  validateDrop:(id <NSDraggingInfo>)info
                  proposedItem:(id)item
            proposedChildIndex:(NSInteger)childIndex
{
    NSDragOperation result = NSDragOperationNone;
    
    if ([item isKindOfClass:[AbstractGroup class]]) {
        result = NSDragOperationGeneric;
    }
    
    return result;
}

- (AbstractGroup *) groupForAbstractId:(int32_t) aid
{
    NSUInteger groupIndex = (aid & 0xFFFF0000) >> 16;
    AbstractGroup *sourceGroup = [self.groups objectAtIndex:groupIndex];
    NSLog(@"aid: %d [%lu]\n", aid, groupIndex);
    NSLog(@"sourceGroupIdx: %lu, %@\n", groupIndex, sourceGroup.name);

    return  sourceGroup;
}

- (Abstract *) removeAbstract:(int32_t) aid
{
    NSOutlineView *outlineView = self.abstractOutline;
    NSUInteger abstractIndex = (aid & 0xFFFF) - 1; // abstract ids start at 1
    AbstractGroup *sourceGroup = [self groupForAbstractId:aid];
    Abstract *abstract = [sourceGroup.abstracts objectAtIndex:abstractIndex];
  
    [outlineView beginUpdates];
    
    [sourceGroup.abstracts removeObjectAtIndex:abstractIndex];
    for (NSUInteger i = abstractIndex; i < sourceGroup.abstracts.count; i++) {
        Abstract *A = [sourceGroup.abstracts objectAtIndex:i];
        int32_t newAid = (sourceGroup.type << 16) | (int32_t) (i + 1);
        NSLog(@"S: new aid: %d [%lu]\n", newAid, i);
        A.aid = newAid;
    }
    
    [outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:abstractIndex]
                             inParent:sourceGroup
                        withAnimation:NSTableViewAnimationEffectNone];
    
    [outlineView endUpdates];
    return abstract;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView
          acceptDrop:(id <NSDraggingInfo>)info
                item:(id)item
          childIndex:(NSInteger)childIndex
{
    if (item == nil)
        return NO;
    

    NSPasteboard *board = [info draggingPasteboard];
    NSData *data = [board dataForType:PT_REORDER];
    int32_t aid;
    [data getBytes:&aid length:sizeof(aid)];
  
    NSLog(@"%@ %ld", item, childIndex);
    NSUInteger ngroups = self.groups.count;
    NSUInteger groupIndex = ((aid & (0xFFFF << 16)) + ngroups-1) % ngroups;
    NSUInteger abstractIndex = (aid & 0xFFFF) - 1; // abstract ids start at 1
      NSLog(@"aid: %d [%lu %lu]\n", aid, groupIndex, abstractIndex);

    AbstractGroup *sourceGroup = [self.groups objectAtIndex:groupIndex];
    Abstract *abstract = [sourceGroup.abstracts objectAtIndex:abstractIndex];
        NSLog(@"sourceGroupIdx: %lu, %@\n", groupIndex, sourceGroup.name);
    [outlineView beginUpdates];
    
    [sourceGroup.abstracts removeObjectAtIndex:abstractIndex];
    for (NSUInteger i = abstractIndex; i < sourceGroup.abstracts.count; i++) {
        Abstract *A = [sourceGroup.abstracts objectAtIndex:i];
        int32_t newAid = (sourceGroup.type << 16) | (int32_t) (i + 1);
        NSLog(@"S: new aid: %d [%lu]\n", newAid, i);
        A.aid = newAid;
    }
    
    [outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:abstractIndex]
                             inParent:sourceGroup
                        withAnimation:NSTableViewAnimationEffectNone];
    
    AbstractGroup *destGroup = item;
    
    if (childIndex == -1)
        childIndex = destGroup.abstracts.count;
    
    
    [destGroup.abstracts insertObject:abstract atIndex:childIndex];
    for (NSUInteger i = childIndex; i < destGroup.abstracts.count; i++) {
        int32_t newAid = (destGroup.type << 16) | ((int32_t) i + 1);
        NSLog(@"new aid: %d [%lu]\n", newAid, i);
        Abstract *A = [destGroup.abstracts objectAtIndex:i];
        A.aid = newAid;

    }
    
    [outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:childIndex]
                             inParent:item
                        withAnimation:NSTableViewAnimationEffectGap];
    
    [outlineView endUpdates];
    
    NSLog(@"acceptDrop\n");
    return NO;
}


@end
