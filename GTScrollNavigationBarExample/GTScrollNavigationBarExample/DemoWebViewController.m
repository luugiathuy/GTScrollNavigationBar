//
//  DemoWebViewController.m
//  GTScrollNavigationBarExample
//
//  Created by Luu Gia Thuy on 23/12/13.
//  Copyright (c) 2013 Luu Gia Thuy. All rights reserved.
//

#import "DemoWebViewController.h"
#import "GTScrollNavigationBar.h"

@interface DemoWebViewController () <UIWebViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIWebView* webView;

@end

@implementation DemoWebViewController

#pragma mark - view lifecycle
- (void)loadView
{
    [super loadView];
    
    float viewWidth = CGRectGetWidth(self.view.frame);
    float viewHeight = CGRectGetHeight(self.view.frame);
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://twitter.com/luugiathuy"]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationController.scrollNavigationBar.scrollView = self.webView.scrollView;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPosition:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPosition:NO];
}

@end
