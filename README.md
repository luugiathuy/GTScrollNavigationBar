# GTScrollNavigationBar

[![CocoaPods Version](https://img.shields.io/cocoapods/v/GTScrollNavigationBar.svg)](http://cocoadocs.org/docsets/GTScrollNavigationBar) [![Build Status](https://travis-ci.org/luugiathuy/GTScrollNavigationBar.svg?branch=master)](https://travis-ci.org/luugiathuy/GTScrollNavigationBar) [![Coverage Status](https://coveralls.io/repos/luugiathuy/GTScrollNavigationBar/badge.svg?branch=master&service=github)](https://coveralls.io/github/luugiathuy/GTScrollNavigationBar?branch=master)

A lightweight scrollable UINavigationBar that follows a UIScrollView. This project was inspired by the navigation bar functionality seen in the Chrome, Facebook and Instagram iOS apps.

=======

![GTScrollNavigationBar Screenshot 1](http://luugiathuy.com/images/GTScrollNavigationBar1.png)&nbsp;![GTScrollNavigationBar Screenshot 2](http://luugiathuy.com/images/GTScrollNavigationBar2.png)

## Installation

### CocoaPods

Add pod `GTScrollNavigationBar` to your Podfile.

### Manually

Add the `GTScrollNavigationBar` folder to your project. `GTScrollNavigationBar` uses ARC, so if you have a project that doesn't use ARC, add the `-fobjc-arc` compiler flag to the `GTScrollNavigationBar` files.

## Usage

Set up the navigation controller to use `GTScrollNavigationBar`:

```objective-c
#import "GTScrollNavigationBar.h"

self.navController = [[UINavigationController alloc] initWithNavigationBarClass:[GTScrollNavigationBar class]
                                                                   toolbarClass:nil];
[self.navController setViewControllers:@[self.mainViewController] animated:NO];
```

In your view controller which has a `UIScrollView`, e.g. `UITableViewController`, set the UIScrollView object to the `GTScrollNavigationBar` in `viewWillAppear:` or `viewDidAppear:` by:

```objective-c
self.navigationController.scrollNavigationBar.scrollView = self.tableView;
```

To unfollow the scrollView, simply set `scrollView` property to `nil`

```objective-c
self.navigationController.scrollNavigationBar.scrollView = nil;
```

Implement `scrollViewDidScrollToTop:` in the view controller to reset the navigation bar's position

```objective-c
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPositionWithAnimation:NO];
}
```

If your scroll view is not a direct subview of your view controller's view, you can specify which view is the one who should change its frame on scroll by using `topLevelView` property:

```objective-c
self.navigationController.scrollNavigationBar.scrollView = self.view;
```

## Contact

[@luugiathuy](http://twitter.com/luugiathuy)
