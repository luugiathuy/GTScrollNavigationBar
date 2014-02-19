//
//  ViewController.m
//  GTScrollNavigationBarExample
//
//  Created by Tosin Afolabi on 18/02/2014.
//  Copyright (c) 2014 Luu Gia Thuy. All rights reserved.
//

#import "GTScrollNavigationBar.h"
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) GTScrollNavigationBar *navBar;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, strong) UITableView *feedView;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navBar.scrollView = self.feedView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /* Set Up Navigation Bar */

	CGFloat navBarHeight = 64.0;
	CGSize screenSize = self.view.frame.size;

	self.navBar = [[GTScrollNavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, navBarHeight)];
    self.navItem = [[UINavigationItem alloc] initWithTitle:@"HHELL"];

    //[self.navBar setBarTintColor:[UIColor blueColor]];
	//[self.navBar setTintColor:[UIColor whiteColor]];

    [self.navBar pushNavigationItem:self.navItem animated:NO];

    /* Set up TableView */

	CGFloat contentViewHeight = screenSize.height - navBarHeight;
	self.feedView = [[UITableView alloc] initWithFrame:CGRectMake(0, navBarHeight, screenSize.width, contentViewHeight)];

	[self.feedView setDelegate:self];
	[self.feedView setDataSource:self];

    [self.view addSubview:self.navBar];
    [self.view addSubview:self.feedView];
    
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

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPosition:YES];
}


@end
