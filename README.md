#GTScrollNavigationBar

A scrollable UINavigationBar that follows a UIScrollView. This project was inspired by the navigation bar functionality seen in the Chrome, Facebook and Instagram iOS apps.

=======

![](http://luugiathuy.com/wp-content/uploads/2013/12/GTScrollNavigationBar1.png)  &nbsp;  ![](http://luugiathuy.com/wp-content/uploads/2013/12/GTScrollNavigationBar2.png)

##Installation
###CocoaPods
Add pod `GTScrollNavigationBar` to your Podfile.
###Manually
Add the `GTScrollNavigationBar` folder to your project. `GTScrollNavigationBar` uses ARC, so if you have a project that doesn't use ARC, just add the `-fobjc-arc` compiler flag to the `GTScrollNavigationBar` files.

##Usage
Set up the navigation controller to use `GTScrollNavigationBar`:
```objective-c
#import "GTScrollNavigationBar.h"

self.navController = [[UINavigationController alloc] initWithNavigationBarClass:[GTScrollNavigationBar class] 
                                                                   toolbarClass:nil];
[self.navController setViewControllers:@[self.mainViewController] animated:NO];
```

In your view controller which has a `UIScrollView`, e.g. `UITableViewController`, set the UIScrollView object to the `GTScrollNavigationBar` in `viewWillAppear:` by:
```objective-c
self.navigationController.scrollNavigationBar.scrollView = self.tableView;
```
To enable a change in color based on scroll position, set `beginColor` and `endColor` properties on the `ScrollNavigationBar`:
```objective-c
self.navigationController.scrollNavigationBar.beginColor = [UIColor blueColor];
self.navigationController.scrollNavigationBar.endColor = [UIColor greenColor];
```

To unfollow the scrollView, simply set `scrollView` property to `nil`
```objective-c
self.navigationController.scrollNavigationBar.scrollView = nil;
```

Implement `scrollViewDidScrollToTop:` in the view controller to reset the navigation bar's position
```objective-c
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPosition:YES];
}
```


##Contact
[@luugiathuy](http://twitter.com/luugiathuy)
