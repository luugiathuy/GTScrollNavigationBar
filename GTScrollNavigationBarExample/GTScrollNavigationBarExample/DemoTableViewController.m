//
//  DemoTableViewController.m
//  GTScrollNavigationBarExample
//
//  Created by Luu Gia Thuy on 21/12/13.
//  Copyright (c) 2013 Luu Gia Thuy. All rights reserved.
//

#import "DemoTableViewController.h"
#import "DemoWebViewController.h"
#import "GTScrollNavigationBar.h"

static int const kTotalRows = 100;
static int const kTotalSections = 10;

@interface DemoTableViewController ()

@end

@implementation DemoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _hasSection = NO;
        _hasRefreshControl = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.accessibilityLabel = @"DemoTableView";
    
    if (self.hasRefreshControl) {
        [self setupRefreshControl];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = @"DemoScrollNavigationBar";
    self.navigationController.scrollNavigationBar.scrollView = self.tableView;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //self.navigationController.scrollNavigationBar.scrollView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom views
- (void)setupRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self setRefreshControl:refreshControl];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.hasSection ? kTotalSections : 1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section %zd", section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.hasSection ? (kTotalRows / kTotalSections) : kTotalRows);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    int row = (int)indexPath.row;
    if (row == 0) {
        cell.textLabel.text = @"WebView Demo";
    } else if (row == 1) {
        cell.textLabel.text = @"Tableview with headers";
    } else if (row == 2) {
        cell.textLabel.text = @"Tableview with UIRefreshControl";
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"Item %i", row];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = (int)indexPath.row;
    if (row == 0) {
        DemoWebViewController* demoWebViewController = [[DemoWebViewController alloc] init];
        [self.navigationController pushViewController:demoWebViewController animated:YES];
    } else {
        DemoTableViewController* demoTableViewController = [[DemoTableViewController alloc] initWithStyle:UITableViewStylePlain];
        if (row == 1) {
            demoTableViewController.hasSection = YES;
        } else if (row == 2) {
            demoTableViewController.hasRefreshControl = YES;
        }
        [self.navigationController pushViewController:demoTableViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.hasSection)
        return 44.0f;
    return 0.0f;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPositionWithAnimation:NO];
}

@end
