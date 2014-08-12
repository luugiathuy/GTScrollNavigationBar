//
//  GTScrollNavigationBar.m
//  GTScrollNavigationBar
//
//  Created by Luu Gia Thuy on 21/12/13.
//  Copyright (c) 2013 Luu Gia Thuy. All rights reserved.
//

#import "GTScrollNavigationBar.h"

#define kNearZero 0.000001f

@interface GTScrollNavigationBar () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPanGestureRecognizer* panGesture;
@property (assign, nonatomic) CGFloat lastContentOffsetY;
@property (assign, nonatomic) BOOL gestureIsActive;

@end

@implementation GTScrollNavigationBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handlePan:)];
    self.panGesture.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarOrientationDidChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                                  object:nil];
}

- (void)setScrollView:(UIScrollView*)scrollView
{
    _scrollView = scrollView;
    [self resetToDefaultPositionWithAnimation:NO];
    
    // remove gesture from current panGesture's view
    if (self.panGesture.view) {
        [self.panGesture.view removeGestureRecognizer:self.panGesture];
    }
    
    if (scrollView) {
        [scrollView addGestureRecognizer:self.panGesture];
    }
}

- (void)resetToDefaultPositionWithAnimation:(BOOL)animated
{
    self.scrollState = GTScrollNavigationBarNone;
    CGRect frame = self.frame;
    frame.origin.y = [self statusBarTopOffset];
    [self setFrame:frame alpha:1.0f animated:animated];
}

- (void)resetToDefaultPosition:(BOOL)animated
{
    [self resetToDefaultPositionWithAnimation:animated];
}

#pragma mark - notifications
- (void)statusBarOrientationDidChange
{
    [self resetToDefaultPositionWithAnimation:NO];
}

- (void)applicationDidBecomeActive
{
    [self resetToDefaultPositionWithAnimation:NO];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - panGesture handler
- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    if (!self.scrollView || gesture.view != self.scrollView) {
        return;
    }
    // Don't try to scroll navigation bar if there's not enough room
    if (self.scrollView.frame.size.height + (self.bounds.size.height * 2) >= self.scrollView.contentSize.height) {
        return;
    }
    
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.scrollState = GTScrollNavigationBarNone;
        self.gestureIsActive = YES;
        self.lastContentOffsetY = contentOffsetY;
        return;
    }
    
    CGFloat deltaY = contentOffsetY - self.lastContentOffsetY;
    if (deltaY < 0.0f) {
        self.scrollState = GTScrollNavigationBarScrollingDown;
    } else if (deltaY > 0.0f) {
        self.scrollState = GTScrollNavigationBarScrollingUp;
    }
    
    CGRect frame = self.frame;
    CGFloat alpha = 1.0f;
    CGFloat maxY = [self statusBarTopOffset];
    CGFloat minY = maxY - CGRectGetHeight(frame) + 1.0f;
    // NOTE: plus 1px to prevent the navigation bar disappears in iOS < 7
    
    bool isScrolling = (self.scrollState == GTScrollNavigationBarScrollingUp ||
                        self.scrollState == GTScrollNavigationBarScrollingDown);
    
    self.gestureIsActive = (gesture.state != UIGestureRecognizerStateEnded &&
                            gesture.state != UIGestureRecognizerStateCancelled);
    
    if (isScrolling && !self.gestureIsActive) {
        if (self.scrollState == GTScrollNavigationBarScrollingDown) {
            frame.origin.y = maxY;
            alpha = 1.0f;
        }
        else if (self.scrollState == GTScrollNavigationBarScrollingUp) {
            frame.origin.y = minY;
            alpha = kNearZero;
        }
        [self setFrame:frame alpha:alpha animated:YES];
    }
    else {
        frame.origin.y -= deltaY;
        frame.origin.y = MIN(maxY, MAX(frame.origin.y, minY));
        
        alpha = (frame.origin.y - (minY + maxY)) / (maxY - (minY + maxY));
        alpha = MAX(kNearZero, alpha);
        
        [self setFrame:frame alpha:alpha animated:NO];
    }
    
    self.lastContentOffsetY = contentOffsetY;
}

#pragma mark - helper methods
- (CGFloat)statusBarTopOffset
{
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)+[UIApplication sharedApplication].statusBarFrame.origin.y;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);
        default:
            break;
    };
    return 64.0f;
}


- (void)setContentInset
{
    
    NSLog(@"inset:%ld,offset:%ld",(long)self.scrollView.contentInset.top,(long)self.scrollView.contentOffset.y);
    // Don't mess the scrollview at first start
    if(self.scrollView.contentInset.top==0 && self.scrollView.contentOffset.y==0){
        return;
    }
    
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.top = self.frame.origin.y+self.frame.size.height;
    self.scrollView.contentInset = insets;
    
    bool isAtTop = (!self.gestureIsActive && self.scrollView.contentOffset.y<=0);
    // Reset contentOffset when scrolling to top after user taps statusbar
    if(isAtTop && self.scrollView.contentOffset.y!=-self.scrollView.contentInset.top){
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x,-self.scrollView.contentInset.top) animated:NO];
    }
}

- (void)setFrame:(CGRect)frame alpha:(CGFloat)alpha animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:@"GTScrollNavigationBarAnimation" context:nil];
    }
    
    CGFloat offsetY = CGRectGetMinY(frame) - CGRectGetMinY(self.frame);
    
    for (UIView* view in self.subviews) {
        bool isBackgroundView = view == [self.subviews objectAtIndex:0];
        bool isViewHidden = view.hidden || view.alpha == 0.0f;
        if (isBackgroundView || isViewHidden)
            continue;
        view.alpha = alpha;
    }
    
    self.frame = frame;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
        [self setContentInset];
    }
    else {
        CGRect parentViewFrame = self.scrollView.superview.frame;
        parentViewFrame.origin.y += offsetY;
        parentViewFrame.size.height -= offsetY;
        self.scrollView.superview.frame = parentViewFrame;
    }
    
    if (animated) {
        [UIView commitAnimations];
    }
}

@end

@implementation UINavigationController (GTScrollNavigationBarAdditions)

@dynamic scrollNavigationBar;

- (GTScrollNavigationBar*)scrollNavigationBar
{
    return (GTScrollNavigationBar*)self.navigationBar;
}

@end
