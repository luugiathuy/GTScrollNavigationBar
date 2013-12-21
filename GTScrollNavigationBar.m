//
//  GTScrollNavigationBar.m
//  GTScrollNavigationBarExample
//
//  Created by Luu Gia Thuy on 21/12/13.
//  Copyright (c) 2013 Luu Gia Thuy. All rights reserved.
//

#import "GTScrollNavigationBar.h"

@interface GTScrollNavigationBar () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPanGestureRecognizer* panGesture;
@property (assign, nonatomic) CGFloat lastContentOffsetY;

@end

@implementation GTScrollNavigationBar

@synthesize scrollView = _scrollView,
            scrollState = _scrollState,
            panGesture = _panGesture,
            lastContentOffsetY = _lastContentOffsetY;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(handlePan:)];
        self.panGesture.delegate = self;
    }
    return self;
}

- (void)setScrollView:(UIScrollView*)scrollView
{
    _scrollView = scrollView;
    
    self.lastContentOffsetY = scrollView.contentOffset.y;
    
    CGRect frame = self.frame;
    frame.origin.y = [self statusBarHeight];
    
    [self setFrame:frame andAlpha:1.0f andScrollViewOffset:scrollView.contentOffset animated:NO];
    
    if (self.panGesture.view) {
        [self.panGesture.view removeGestureRecognizer:self.panGesture];
    }
    [scrollView addGestureRecognizer:self.panGesture];
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
    if (gesture.view != self.scrollView)
        return;
    
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    if (contentOffsetY < 0.0f)
        return;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.lastContentOffsetY = contentOffsetY;
        return;
    }
    
    CGFloat deltaY = contentOffsetY - self.lastContentOffsetY;
    
    CGRect frame = self.frame;
    
    CGFloat maxY = [self statusBarHeight];
    CGFloat minY = maxY - [self defaultNavigationBarHeight];

    frame.origin.y -= deltaY;
    frame.origin.y = MIN(maxY, MAX(frame.origin.y, minY));
    
    float alpha = (frame.origin.y - minY) / (maxY - minY);
    alpha = MAX(0.000001f, alpha);
    
    if (deltaY < 0.0f)
        self.scrollState = GTScrollNavigationBarScrollingDown;
    else if (deltaY > 0.0f)
        self.scrollState = GTScrollNavigationBarScrollingUp;
    
    CGPoint newContentOffset = self.scrollView.contentOffset;
    bool isAnimation = NO;
    
    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateCancelled)
    {
        CGFloat contentOffsetYDelta = 0.0f;
        if (self.scrollState == GTScrollNavigationBarScrollingDown ) {
            contentOffsetYDelta = maxY - frame.origin.y;
            frame.origin.y = maxY;
            alpha = 1.0f;
        }
        else if (self.scrollState == GTScrollNavigationBarScrollingUp) {
            contentOffsetYDelta = minY - frame.origin.y;
            frame.origin.y = minY;
            alpha = 0.000001f;
        }
        newContentOffset = CGPointMake(self.scrollView.contentOffset.x,
                                       contentOffsetY - contentOffsetYDelta);
        isAnimation = YES;
    }
    
    [self setFrame:frame andAlpha:alpha andScrollViewOffset:newContentOffset animated:isAnimation];
    
    self.lastContentOffsetY = contentOffsetY;
}

#pragma mark - helper methods
- (CGFloat)statusBarHeight
{
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);
        default:
            break;
    };
    return 0.0f;
}

- (CGFloat)defaultNavigationBarHeight
{
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return 44.0f;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return 30.0f;
        default:
            break;
    };
    return 0.0f;
}

- (void)setFrame:(CGRect)frame
        andAlpha:(CGFloat)alpha andScrollViewOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:@"GTScrollNavigationBarAnimation" context:nil];
    }
    
    for (UIView* view in self.subviews)
    {
        bool isBackgroundView = view == [self.subviews objectAtIndex:0];
        bool isViewHidden = view.hidden || view.alpha == 0.0f;
        if (isBackgroundView || isViewHidden)
            continue;
        view.alpha = alpha;
    }
    self.frame = frame;
    self.scrollView.contentOffset = contentOffset;
    
    if (animated) {
        [UIView commitAnimations];
    }
}

@end
