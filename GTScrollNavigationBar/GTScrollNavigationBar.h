//
//  GTScrollNavigationBar.h
//  GTScrollNavigationBar
//
//  Created by Luu Gia Thuy on 21/12/13.
//  Copyright (c) 2013 Luu Gia Thuy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GTScrollNavigationBarNone,
    GTScrollNavigationBarScrollingDown,
    GTScrollNavigationBarScrollingUp
} GTScrollNavigationBarState;

@interface GTScrollNavigationBar : UINavigationBar

@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) GTScrollNavigationBarState scrollState;

- (void)resetToDefaultPosition:(BOOL)animated;

@end

@interface UINavigationController (GTScrollNavigationBarAdditions)

@property(strong, nonatomic, readonly) GTScrollNavigationBar *scrollNavigationBar;

@end
