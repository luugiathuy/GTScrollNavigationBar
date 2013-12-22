GTScrollNavigationBar
=====================

A scrollable UINavigationBar that follows a UIScrollView. This project was inspired by the navigation bar functionality seen in the Chrome, Facebook and Instagram iOS apps.

=======

![](http://luugiathuy.com/wp-content/uploads/2013/12/GTScrollUINavigationBar1.png)  &nbsp;  ![](http://luugiathuy.com/wp-content/uploads/2013/12/GTScrollUINavigationBar2.png)

##Usage

Copy folder GTScrollNavigationBar to your project. In your app delegate, set up the navigation controller to use GTScrollNavigationBar
```
#import "GTScrollNavigationBar.h"

self.navController = [[UINavigationController alloc] initWithNavigationBarClass:[GTScrollNavigationBar class] 
                                                                   toolbarClass:nil];
```

in your view controller which has a UIScrollView, e.g. UITableViewController, assign UIScrollView object to your navigation bar in ```viewWillAppear:```
```
GTScrollNavigationBar* navigationBar = (GTScrollNavigationBar*)self.navigationController.navigationBar;
navigationBar.scrollView = self.tableView;
```
To unfollow a UIScrollView, simply set scrollView propery to nil
```
navigationBar.scrollView = nil;
```
##Contact
[@luugiathuy](http://twitter.com/luugiathuy)
