GTScrollNavigationBar
=====================

An iOS7 scrollable UINavigationBar that follows a UIScrollView. This project was inspired by the navigation bar functionality seen in the Chrome, Facebook and Instagram iOS app.

##Usage

In your app delegate, set up the navigation controller to use GTScrollNavigationBar
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

##Contact
[@luugiathuy](http://twitter.com/luugiathuy)
