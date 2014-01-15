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

@interface DemoTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DemoTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height -  44, 320.0f, 44.0f)];
    toolbar.backgroundColor = [UIColor redColor];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, toolbar.frame.origin.y) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:toolbar];
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    if( floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //iOS 7 code
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);

    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"DemoScrollNavigationBar";
    self.navigationController.scrollNavigationBar.scrollView = self.tableView;
    self.navigationController.scrollNavigationBar.keepSubviewsLayout = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.scrollNavigationBar.scrollView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor greenColor];
    }
    
    // Configure the cell...
    int row = (int)indexPath.row;
    if (row==0) {
        cell.textLabel.text = @"WebView Demo";
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
        DemoTableViewController* demoTableViewController = [[DemoTableViewController alloc] init];
        [self.navigationController pushViewController:demoTableViewController animated:YES];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPosition:YES];
}

@end
