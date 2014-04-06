/**
 *  UIColor + ColorDifference
 *  Returns a color between two colors based on a percentage difference
 *  Based on: http://stackoverflow.com/questions/15757872/manually-color-fading-from-one-uicolor-to-another
 */

@interface UIColor (ColorDifference)

+ (UIColor *)colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor percent:(float)percent;

@end

@implementation UIColor (ColorDifference)

+ (UIColor *)colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor percent:(float)percent
{
    float dec = percent / 100.f;
    CGFloat fRed, fBlue, fGreen, fAlpha;
    CGFloat tRed, tBlue, tGreen, tAlpha;
    CGFloat red, green, blue, alpha;
    
    if(CGColorGetNumberOfComponents(fromColor.CGColor) == 2) {
        [fromColor getWhite:&fRed alpha:&fAlpha];
        fGreen = fRed;
        fBlue = fRed;
    }
    else {
        [fromColor getRed:&fRed green:&fGreen blue:&fBlue alpha:&fAlpha];
    }
    if(CGColorGetNumberOfComponents(toColor.CGColor) == 2) {
        [toColor getWhite:&tRed alpha:&tAlpha];
        tGreen = tRed;
        tBlue = tRed;
    }
    else {
        [toColor getRed:&tRed green:&tGreen blue:&tBlue alpha:&tAlpha];
    }
    
    red = (dec * (tRed - fRed)) + fRed;
    green = (dec * (tGreen - fGreen)) + fGreen;
    blue = (dec * (tBlue - fBlue)) + fBlue;
    alpha = (dec * (tAlpha - fAlpha)) + fAlpha;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end

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

static BOOL IS_7;

@synthesize scrollView = _scrollView,
scrollState = _scrollState,
panGesture = _panGesture,
lastContentOffsetY = _lastContentOffsetY;

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
    
    //Check if ios 7 for changing bar background color
    IS_7 = [UINavigationBar instancesRespondToSelector:@selector(barTintColor)] ? YES : NO;
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
    
    CGRect defaultFrame = self.frame;
    defaultFrame.origin.y = [self statusBarHeight];
    [self setFrame:defaultFrame alpha:1.0f colorPercentage:100.0f animated:NO];
    
    // remove gesture from current panGesture's view
    if (self.panGesture.view) {
        [self.panGesture.view removeGestureRecognizer:self.panGesture];
    }
    
    if (scrollView) {
        [scrollView addGestureRecognizer:self.panGesture];
    }
}

- (void)resetToDefaultPosition:(BOOL)animated
{
    CGRect frame = self.frame;
    frame.origin.y = [self statusBarHeight];
    [self setFrame:frame alpha:1.0f colorPercentage:100.0f animated:NO];
}

#pragma mark - notifications
- (void)statusBarOrientationDidChange
{
    [self resetToDefaultPosition:NO];
}

- (void)applicationDidBecomeActive
{
    [self resetToDefaultPosition:NO];
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
    
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    if (contentOffsetY < -self.scrollView.contentInset.top) {
        return;
    }
    
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
    
    CGFloat statusBarHeight = [self statusBarHeight];
    CGFloat maxY = statusBarHeight;
    CGFloat minY = maxY - CGRectGetHeight(frame) + 1.0f;
    // NOTE: plus 1px to prevent the navigation bar disappears in iOS < 7
    
    bool isScrollingAndGestureEnded = (gesture.state == UIGestureRecognizerStateEnded ||
                                       gesture.state == UIGestureRecognizerStateCancelled) &&
    (self.scrollState == GTScrollNavigationBarScrollingUp ||
     self.scrollState == GTScrollNavigationBarScrollingDown);
    if (isScrollingAndGestureEnded) {
        CGFloat contentOffsetYDelta = 0.0f;
        if (self.scrollState == GTScrollNavigationBarScrollingDown) {
            contentOffsetYDelta = maxY - frame.origin.y;
            frame.origin.y = maxY;
            alpha = 1.0f;
        }
        else if (self.scrollState == GTScrollNavigationBarScrollingUp) {
            contentOffsetYDelta = minY - frame.origin.y;
            frame.origin.y = minY;
            alpha = kNearZero;
            
        }
        
        [self setFrame:frame alpha:alpha colorPercentage:alpha*100 animated:YES];
        
        if (!self.scrollView.decelerating) {
            CGPoint newContentOffset = CGPointMake(self.scrollView.contentOffset.x,
                                                   contentOffsetY - contentOffsetYDelta);
            [self.scrollView setContentOffset:newContentOffset animated:YES];
        }
    }
    else {
        frame.origin.y -= deltaY;
        frame.origin.y = MIN(maxY, MAX(frame.origin.y, minY));
        
        alpha = (frame.origin.y - (minY + statusBarHeight)) / (maxY - (minY + statusBarHeight));
        alpha = MAX(kNearZero, alpha);
        
        [self setFrame:frame alpha:alpha colorPercentage:alpha*100 animated:NO];
    }
    
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

- (void)setFrame:(CGRect)frame alpha:(CGFloat)alpha colorPercentage:(CGFloat)colorPercentage animated:(BOOL)animated
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
    
    //Animate color if to and from colors are defined
    if (self.beginColor && self.endColor) {
        UIColor *color = [UIColor colorFromColor:self.endColor toColor:self.beginColor percent:colorPercentage];

        if (IS_7) {
            self.barTintColor = color;
        }
        else {
            self.tintColor = color;
        }
    }
    
    self.frame = frame;
    
    CGRect parentViewFrame = self.scrollView.superview.frame;
    parentViewFrame.origin.y += offsetY;
    parentViewFrame.size.height -= offsetY;
    self.scrollView.superview.frame = parentViewFrame;
    
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
