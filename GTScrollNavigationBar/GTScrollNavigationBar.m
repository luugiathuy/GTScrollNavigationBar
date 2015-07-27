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
    self.panGesture.cancelsTouchesInView = NO;
    
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

#pragma mark - Properties
- (void)setScrollView:(UIScrollView*)scrollView
{
    [self resetToDefaultPositionWithAnimation:NO];
    
    _scrollView = scrollView;
    
    // remove gesture from current panGesture's view
    if (self.panGesture.view) {
        [self.panGesture.view removeGestureRecognizer:self.panGesture];
    }
    
    if (scrollView) {
        [scrollView addGestureRecognizer:self.panGesture];
    }
}

#pragma mark - Public methods
- (void)resetToDefaultPositionWithAnimation:(BOOL)animated
{
    self.scrollState = GTScrollNavigationBarNone;
    CGRect frame = self.frame;
    frame.origin.y = [self statusBarTopOffset];
    [self setFrame:frame alpha:1.0f animated:animated];
}

#pragma mark - Notifications
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
    if (self.scrollView.frame.size.height + (self.bounds.size.height * 2) >=
        self.scrollView.contentSize.height) {
        return;
    }
    
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    // Reset scrollState when the gesture began
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.scrollState = GTScrollNavigationBarNone;
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
    
    CGFloat contentInsetTop = self.scrollView.contentInset.top;
    bool isBouncePastTopEdge = contentOffsetY < -contentInsetTop;
    if (isBouncePastTopEdge && CGRectGetMinY(frame) == maxY) {
        self.lastContentOffsetY = contentOffsetY;
        return;
    }
    
    bool isScrolling = (self.scrollState == GTScrollNavigationBarScrollingUp ||
                        self.scrollState == GTScrollNavigationBarScrollingDown);
    
    bool gestureIsActive = (gesture.state != UIGestureRecognizerStateEnded &&
                            gesture.state != UIGestureRecognizerStateCancelled);
    
    if (isScrolling && !gestureIsActive) {
        // Animate navigation bar to end position
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
        // Move navigation bar with the change in contentOffsetY
        frame.origin.y -= deltaY;
        frame.origin.y = MIN(maxY, MAX(frame.origin.y, minY));
        
        alpha = (frame.origin.y - (minY + maxY)) / (maxY - (minY + maxY));
        alpha = MAX(kNearZero, alpha);
        
        [self setFrame:frame alpha:alpha animated:NO];
    }
    
    // When panning down at begining of scrollView and the bar is expanding, do not update lastContentOffsetY
    if (isBouncePastTopEdge && CGRectGetMinY(frame) != maxY) {
        
    } else {
        self.lastContentOffsetY = contentOffsetY;
    }
}

#pragma mark - helper methods
- (CGFloat)statusBarTopOffset
{
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    return MIN(CGRectGetMaxX(statusBarFrame), CGRectGetMaxY(statusBarFrame));
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
    

    if (self.scrollView) {
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
