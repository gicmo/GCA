//
//  AbstractsListTVC.m
//  NI2013
//
//  Created by Christian Kellner on 17/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "AbstractsListTVC.h"
#import "AbstractInfoCell.h"
#import "AbstractVC.h"

#import <CoreData/CoreData.h>
#import "UIColor+ConferenceKit.h"
#import "CKDataStore.h"
#import "Abstract.h"
#import "Author.h"
#import "Author+Format.h"

@interface AbstractsListTVC () <AbstrarctVCDelegate, UISearchBarDelegate> {
    BOOL showFav;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starButton;

@property (strong, nonatomic, readonly) UIImage *starEmpty;
@property (strong, nonatomic, readonly) UIImage *starFilled;

@property (nonatomic, strong) NSFetchedResultsController *fetchResultsCtrl;
@property (nonatomic, copy) NSIndexPath *curAbstract;
@end

@implementation AbstractsListTVC
@synthesize starEmpty = _starEmpty;
@synthesize starFilled = _starFilled;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"AbstractInfoCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"AbstractInfoCell"];
    
    self.tableView.rowHeight = 94;
    self.navigationController.toolbar.tintColor = [UIColor ckColor];
    self.navigationController.toolbar.hidden = YES;
    self.navigationController.navigationBar.tintColor = [UIColor ckColor];
    [self setupFetchedResultsController];
    
    self.searchBar.tintColor = [UIColor ckColor];
    self.searchBar.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self setupForiPad];
    } else {
        GLuint height = self.tableView.tableHeaderView.frame.size.height;
        [self.tableView setContentOffset:CGPointMake(0, height)];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.curAbstract) {
        [self.tableView selectRowAtIndexPath:self.curAbstract animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }

    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - NSFetchResultsController
- (void)setupFetchedResultsController
{
    CKDataStore *store = [CKDataStore defaultStore];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Abstract"];
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"aid" ascending:YES];
    
    request.sortDescriptors = [NSArray arrayWithObject:sortDesc];
    self.fetchResultsCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                managedObjectContext:store.managedObjectContext
                                                                  sectionNameKeyPath:@"session"
                                                                           cacheName:nil];
    [self.fetchResultsCtrl performFetch:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchResultsCtrl sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResultsCtrl sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if 0
    UITableViewCell *c1 = [tableView dequeueReusableCellWithIdentifier:@"notUsed" forIndexPath:indexPath];
    return c1;
#endif
    
    static NSString *CellIdentifier = @"AbstractInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (![cell isKindOfClass:[AbstractInfoCell class]]) {
        NSLog(@"Warning! Was not AbstractInfoCell!");
        return cell;
    }
    AbstractInfoCell *infoCell = (AbstractInfoCell *)cell;
    Abstract *abstract = [self.fetchResultsCtrl objectAtIndexPath:indexPath];
    
    infoCell.title.text = abstract.title;
    Author *author = [abstract.authors objectAtIndex:0];
    
    UIFont *font = infoCell.authors.font;
    NSMutableString *authorLabel = [[NSMutableString alloc] initWithString:[author formatName]];
    
    
    for (int idx = 1; idx < [abstract.authors count]; idx++) {
        Author *coAuthor = [abstract.authors objectAtIndex:idx];
        
        NSString *separator;
        if (idx + 1 == [abstract.authors count])
            separator = @" & ";
        else
            separator = @", ";
        
        [authorLabel appendFormat:@"%@%@", separator, [coAuthor formatName]];
    }
    
    //FIXME
    if ([authorLabel sizeWithAttributes:@{NSFontAttributeName: font}].width < infoCell.frame.size.width - 40) {
        infoCell.authors.text = authorLabel;
    } else {
        infoCell.authors.text = [NSString stringWithFormat:@"%@ et al.", [author formatName]];
    }
    
    if (abstract.isFavorite) {
        infoCell.title.textColor = [UIColor ckColor];
    } else {
        infoCell.title.textColor = [UIColor blackColor];
    }
    
    
    return cell;
}


// User selected an abstract
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.curAbstract = indexPath;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self iPadSelectAbstractAtIndexPath:indexPath];
    } else {
        UITableViewCell *sender = [tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"selectAbstract" sender:sender];
    }
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

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResultsCtrl sections] objectAtIndex:section];
    
    NSString *name = [sectionInfo name];
    return name;
}


#pragma mark - Abstract View delegates
- (void)abstractVC:(AbstractVC *)controller nextAbstract:(Abstract *)abstract
{
    NSIndexPath *path = self.curAbstract; //[self.tableView indexPathForSelectedRow];
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
    
    self.curAbstract = path;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
        UIInterfaceOrientationIsLandscape ([UIApplication sharedApplication].statusBarOrientation)) {
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    controller.abstract = abstract;
}

-(void)prevAbstract:(AbstractVC *)controller
{
    NSIndexPath *path = self.curAbstract; //[self.tableView indexPathForSelectedRow];
    
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
    
    self.curAbstract = path;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
        UIInterfaceOrientationIsLandscape ([UIApplication sharedApplication].statusBarOrientation)) {
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    controller.abstract = abstract;
    
    return;
}

- (void)abstractChanged:(AbstractVC *)controller
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark -
#pragma mark iPad


-(void)setupForiPad
{
    AbstractVC *avc = [self.splitViewController.viewControllers objectAtIndex:1];
    avc.delegate = self;
    avc.navigationController.toolbar.tintColor = [UIColor ckColor];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    self.curAbstract = indexPath;
    [self iPadSelectAbstractAtIndexPath:self.curAbstract];
    
}

- (void)iPadSelectAbstractAtIndexPath:(NSIndexPath *)indexPath
{
    Abstract *abstract = [self.fetchResultsCtrl objectAtIndexPath:indexPath];
    AbstractVC *avc = [self.splitViewController.viewControllers objectAtIndex:1];
    avc.abstract = abstract;
}

#pragma mark - Search Bar delegates
#define SEARCH_PREDICATE @"(title CONTAINS[c] %@ OR (ANY authors.lastName CONTAINS[c] %@) OR (ANY authors.lastName CONTAINS[c] %@))"
#define SEARCH_REDICATE_FAV @"isFavorite == YES AND ((title CONTAINS[c] %@ OR (ANY authors.lastName CONTAINS[c] %@) OR (ANY authors.lastName CONTAINS[c] %@)))"
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
        predicate = [NSPredicate predicateWithFormat:predString, searchText, searchText, searchText];
    }

    [self dataPerformQuery:predicate];
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


#pragma mark -

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
        self.starButton.tintColor = [UIColor ckColor];
        predicate = nil;
    }
    
    self.starButton.image = img;
    [self dataPerformQuery:predicate];
}

-(void) dataPerformQuery:(NSPredicate *)predicate
{
    self.fetchResultsCtrl.fetchRequest.predicate = predicate;
    [self.fetchResultsCtrl performFetch:nil];
    [self.tableView reloadData];

    self.curAbstract = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        AbstractVC *avc = [self.splitViewController.viewControllers objectAtIndex:1];
        avc.abstract = nil;
    }
}

@end
