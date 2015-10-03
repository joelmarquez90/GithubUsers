//
//  MasterViewController.m
//  GithubUsers
//
//  Created by Joel Márquez on 10/2/15.
//  Copyright (c) 2015 Joel. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SubtitleTableViewCell.h"
#import "UsersManager.h"
#import "User.h"

#import "MBProgressHUD.h"

#define RowHeight 100

@interface MasterViewController () <UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL shouldShowSearchResults;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *filteredDataSource;

@property (nonatomic, assign) BOOL alphabeticalOrder;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Public Repositories", nil);
    self.tableView.rowHeight = RowHeight;
    [self.tableView registerClass:SubtitleTableViewCell.class forCellReuseIdentifier:@"Cell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort", nil) style:UIBarButtonItemStylePlain target:self action:@selector(sortUsers)];
    
    [self setupSearchController];
    
    self.dataSource = [NSMutableArray array];
    
    [self loadData];
}

- (void)setupSearchController
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search Users", nil);
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

/*
 * Loads more users from the server and then sorts them
 */
- (void)loadData
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[[UsersManager sharedInstance] getUsers] subscribeNext:^(NSArray *users) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        [self.dataSource addObjectsFromArray:users];
        [self doSortUsers];
    } error:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        User *user = self.dataSource[indexPath.row];
        [[segue destinationViewController] setModel:user];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    SubtitleTableViewCell *cell = (SubtitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    User *user = self.dataSource[indexPath.row];
    cell.model = user;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return RowHeight;
}

/*
 * We have to implement this method in order to know when the tableView is in the last row, fetching new users
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If it's the last element and we are not searching, we load more data
    if (indexPath.row == self.dataSource.count - 1 && !self.shouldShowSearchResults) {
        [self loadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowDetail" sender:self];
}

#pragma mark - Sorting

/*
 * Toggles the sort method and then perform the sort
 */
- (void)sortUsers
{
    self.alphabeticalOrder = !self.alphabeticalOrder;
    [self doSortUsers];
}

/*
 * Sorts the user array alphabetically or in ascending order and then reloads the table
 */
- (void)doSortUsers
{
    self.dataSource = [NSMutableArray arrayWithArray:[self.dataSource sortedArrayUsingComparator:^NSComparisonResult(User *user1, User *user2) {
        if (self.alphabeticalOrder) {
            return [[user1.username lowercaseString] compare:[user2.username lowercaseString]];
        }
        else {
            return [user1.ID compare:user2.ID];
        }
    }]];
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.filteredDataSource = [NSMutableArray arrayWithArray:_dataSource];
    self.shouldShowSearchResults = YES;
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.shouldShowSearchResults = NO;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (!self.shouldShowSearchResults) {
        self.shouldShowSearchResults = YES;
        [self.tableView reloadData];
    }
    
    [self.searchController.searchBar resignFirstResponder];
}

#pragma mark - UISearchResultsUpdating

/*
 * Each time a letter is entered or removed from the Search Bar, this delegate gets called.
 */
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = self.searchController.searchBar.text;
    
    NSMutableArray *searchResults = [_dataSource mutableCopy];
    
    NSString *strippedString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    for (NSString *searchString in searchItems) {
        
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"username"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];

    self.filteredDataSource = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - Current DataSource

/*
 * We override the dataSource getter in order to return the current dataSource (filtered or not)
 */
- (NSMutableArray *)dataSource
{
    return self.shouldShowSearchResults ? self.filteredDataSource : _dataSource;
}

@end