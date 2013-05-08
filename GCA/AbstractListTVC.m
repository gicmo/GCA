//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import "AbstractListTVC.h"
#import "Abstract.h"
#import "Author.h"
#import "GCAAppDelegate.h"
#import "AbstractVC.h"
#import "GCAAppDelegate.h"
#import "UIColor+GCA.h"
#import <CoreData/CoreData.h>

@interface AbstractListTVC () <UISearchBarDelegate, AbstrarctVCDelegate>
{
    BOOL showFav;
}

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSFetchedResultsController *fetchResultsCtrl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starButton;
@property (strong, nonatomic, readonly) UIImage *starEmpty;
@property (strong, nonatomic, readonly) UIImage *starFilled;

@property (readonly) UIColor *tmColor;
@end

@implementation AbstractListTVC

#pragma mark - Properties
@synthesize fetchResultsCtrl = _fetchResultsCtrl;
@synthesize searchBar = _searchBar;
@synthesize starButton = _starButton;
@synthesize starEmpty = _starEmpty;
@synthesize starFilled = _starFilled;

-(UIColor *)tmColor
{
  return [UIColor tmColor];
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    GCAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    GCAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    GCAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.persistentStoreCoordinator;
}

- (UIImage *)starEmpty
{
    if (!_starEmpty) {
        _starEmpty = [UIImage imageNamed:@"00-StarWhite"];
    }
    return _starEmpty;
}

- (UIImage *)starFilled
{
    if (!_starFilled) {
        _starFilled = [UIImage imageNamed:@"00-StarWhiteFilled"];
    }
    return _starFilled;
}

#pragma mark -

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    GLuint height = self.tableView.tableHeaderView.frame.size.height;
    [self.tableView setContentOffset:CGPointMake(0, height)]; 
    
    self.navigationController.navigationBar.tintColor = self.tmColor;
    self.searchBar.tintColor = self.tmColor;
    
    
    self.clearsSelectionOnViewWillAppear = NO;
    [self setupFetchedResultsController];
    self.searchBar.delegate = self;
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setStarButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
         
#pragma mark - NSFetchResultsController
- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Abstract"];
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"aid" ascending:YES];
    
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    self.fetchResultsCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                managedObjectContext:self.managedObjectContext
                                                                  sectionNameKeyPath:@"session"
                                                                           cacheName:nil];
    [self.fetchResultsCtrl performFetch:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchResultsCtrl sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResultsCtrl sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AbstractCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Abstract *abstract = [self.fetchResultsCtrl objectAtIndexPath:indexPath];
    cell.textLabel.text = abstract.title;
    Author *author = [abstract.authors objectAtIndex:0];

    UIFont *font = cell.detailTextLabel.font;
    NSMutableString *authorLabel = [[NSMutableString alloc] initWithString:author.name];
    
    for (int idx = 1; idx < [abstract.authors count]; idx++) {
        Author *coAuthor = [abstract.authors objectAtIndex:idx];
        
        NSString *separator;
        if (idx + 1 == [abstract.authors count])
            separator = @" & ";
        else 
            separator = @", ";
        
        [authorLabel appendFormat:@"%@%@", separator, coAuthor.name];
    }
    
    if ([authorLabel sizeWithFont:font].width < cell.frame.size.width - 40) {
        cell.detailTextLabel.text = authorLabel;
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ et al.", author.name];
    }
    
    if (abstract.isFavorite) {
        cell.textLabel.textColor = self.tmColor;
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}


#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResultsCtrl sections] objectAtIndex:section];
    
    NSString *name = [sectionInfo name];
    unichar ch = [name characterAtIndex:0];
    NSString *session = @"";
    switch (ch) {
            
        case 'O':
            session = @"Invited Talk";
            break;
        case 'T':
            session = @"Poster Session I - Thursday";
            break;
        case 'F':
            session = @"Poster Session II - Friday";
            break;
        default:
            break;
    }
    
    return session;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Data
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResultsCtrl sections] objectAtIndex:section];
    
    NSString *name = [sectionInfo name];
    unichar ch = [name characterAtIndex:0];
    NSString *session = @"";
    switch (ch) {
            
        case 'O':
            session = @"Invited Talk";
            break;
        case 'T':
            session = @"Poster Session I - Thursday";
            break;
        case 'F':
            session = @"Poster Session II - Friday";
            break;
        default:
            break;
    }

    NSString *topic = [name substringFromIndex:2];
    
    // View
    
    CGFloat width = self.tableView.contentSize.width;
    
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, width, 40.0)];
    
    UIColor *bgColor = self.tmColor;
	customView.backgroundColor = bgColor;
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    CGSize size = [session sizeWithFont:font
                      constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                          lineBreakMode:UILineBreakModeClip];
    
	// Topic
	UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 3.0, width - 10, size.height)];
	topicLabel.backgroundColor = [UIColor clearColor];
	topicLabel.opaque = NO;
	topicLabel.textColor = [UIColor whiteColor];
	topicLabel.highlightedTextColor = [UIColor whiteColor];
	topicLabel.font = [UIFont boldSystemFontOfSize:12];
    
    topicLabel.text = topic;
    [customView addSubview:topicLabel];
    
    // Separator
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height + 4, width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:0.9];
    [customView addSubview:lineView];
    
    // Session
    UILabel *sessionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, size.height + 7, width - 15, size.height)];
	sessionLabel.backgroundColor = [UIColor clearColor];
	sessionLabel.opaque = NO;
	sessionLabel.textColor = [UIColor whiteColor];
	sessionLabel.highlightedTextColor = [UIColor whiteColor];
	sessionLabel.font = [UIFont boldSystemFontOfSize:12];
    sessionLabel.textAlignment = UITextAlignmentRight;
    
    sessionLabel.text = session;
    [customView addSubview:sessionLabel];
    
	return customView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Abstract *abstract = [self.fetchResultsCtrl objectAtIndexPath:indexPath];
        
        //UIViewController *vc = [self.splitViewController.viewControllers objectAtIndex:1];
        //if ([vc respondsToSelector:@selector(setAbstract:)]) {
        //    [vc performSelector:@selector(setAbstract:) withObject:abstract];
       //}
    //}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Abstract *abstract = [self.fetchResultsCtrl objectAtIndexPath:indexPath];
    
    if ([segue.destinationViewController isKindOfClass:[AbstractVC class]]) {
        AbstractVC *avc = segue.destinationViewController;
        avc.abstract = abstract;
        avc.delegate = self;
    }
    
}



#pragma mark - Search Bar delegates
#define SEARCH_PREDICATE @"(title CONTAINS[c] %@ OR (ANY authors.name CONTAINS[c] %@))"
#define SEARCH_REDICATE_FAV @"isFavorite == YES AND ((title CONTAINS[c] %@ OR (ANY authors.name CONTAINS[c] %@)))"
#define FAV_PREDICATE @"isFavorite == YES"
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *predicate;
    if ([searchText isEqualToString:@""]) {
        predicate = showFav ? [NSPredicate predicateWithFormat:FAV_PREDICATE] : nil;
    } else {
        NSString *predString;
        if (showFav) {
            predString = SEARCH_REDICATE_FAV;
        } else {
            predString = SEARCH_PREDICATE;
        }
        predicate = [NSPredicate predicateWithFormat:predString, searchText, searchText];
    }
    
    self.fetchResultsCtrl.fetchRequest.predicate = predicate;
    [self.fetchResultsCtrl performFetch:nil];
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

- (IBAction)scrollToSearchBar:(id)sender
{
    CGRect top = CGRectMake(0, 0, 20, 20);
    [self.tableView scrollRectToVisible:top animated:YES];
}

#pragma mark - Abstract View delegates
- (void)abstractVC:(AbstractVC *)controller nextAbstract:(Abstract *)abstract
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResultsCtrl sections] objectAtIndex:path.section];
    
    NSInteger section;
    NSInteger row;
    
    if (path.row + 1 < [sectionInfo numberOfObjects]) {
        row = path.row + 1;
        section = path.section;
    } else {
        row = 0;
        section = path.section + 1;
        if (section >= [[self.fetchResultsCtrl sections] count]) {
            return;
        }
    }
    
    path = [NSIndexPath indexPathForRow:row inSection:section];
    abstract = [self.fetchResultsCtrl objectAtIndexPath:path];
    if (!abstract) {
        NSLog(@"Warning!! Tried to access OOB abstract from AbstractVC");
        return;
    }
    
    [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    controller.abstract = abstract;
    return;
}

-(void)prevAbstract:(AbstractVC *)controller
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    NSInteger section;
    NSInteger row = path.row - 1;

    if (row >= 0) {
        section = path.section;
    } else {
        section = path.section - 1;
        
        if (section == -1) {
            //NSLog (@"Index OO:");
            return;
        }
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResultsCtrl sections] objectAtIndex:section];
        row = [sectionInfo numberOfObjects] - 1;
    }
    
    if (section == -1 || row == -1) {
        //NSLog (@"Index OOB: r:%d s:%d\n", row, section);
        return;
    }
    
    path = [NSIndexPath indexPathForRow:row inSection:section];
    Abstract *abstract = [self.fetchResultsCtrl objectAtIndexPath:path];
    if (!abstract) {
        //NSLog(@"Warning!! Tried to access OOB abstract from AbstractVC");
        return;
    }
    
    [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    controller.abstract = abstract;
    
    return;
}

- (void)abstractChanged:(AbstractVC *)controller
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

- (IBAction)switchStarred:(id)sender
{
    showFav = ! showFav;
    NSPredicate *predicate;
    UIImage *img = nil;
    if (showFav) {
        img = self.starFilled;
        self.starButton.tintColor = [UIColor colorWithRed:42/255.0 green:93/255.0 blue:186/255.0 alpha:1.0];
        predicate = [NSPredicate predicateWithFormat:FAV_PREDICATE];
    } else {
        img = self.starEmpty;
        self.starButton.tintColor = self.tmColor;
        predicate = nil;
    }

    self.starButton.image = img;

    self.fetchResultsCtrl.fetchRequest.predicate = predicate;
    [self.fetchResultsCtrl performFetch:nil];
    [self.tableView reloadData];
}




@end
