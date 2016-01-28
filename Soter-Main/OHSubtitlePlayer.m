//  Created by Oleg on 2015.
//  Copyright (c) 2015 Oleg Hnidets. All rights reserved.
//

#import "OHSubtitlePlayer.h"

#import "OHSubtitleView.h"
#import "OHSubtitleLabel.h"

#import "UIView+Xib.h"
#import "OHSubtitleParser.h"

static NSString *const kRateProperty        = @"rate";
static NSString *const kVisibilityProperty  = @"alpha";
static NSString *const kBoundsProperty      = @"bounds";
static NSString *const kVideoBoundsProperty = @"videoBounds";
static NSString *const kAVAlphaUpdatingView = @"AVAlphaUpdatingView";
static NSString *const kUITransitionView    = @"UITransitionView";

static void *kRateContext        = &kRateContext;
static void *kBoundsContext      = &kBoundsContext;
static void *kVideoBoundsContext = &kVideoBoundsContext; // We need observe video bounds 'cause it observes AVUpdatingView. AVUpdatingView doesn't present when only bounds are changed.
static void *kVisibilityContext  = &kVisibilityContext;

NSString *const OHSubtitlePlayerDidEnterFullScreen = @"SubtitlePlayerDidEnterFullScreen";
NSString *const OHSubtitlePlayerDidExitFullScreen  = @"SubtitlePlayerDidExitFullScreen";

@interface OHSubtitlePlayer ()

@property (nonatomic, strong, readwrite) AVPlayerViewController *avPlayerViewController;
@property (nonatomic, strong, readwrite) OHSubtitleView *subtitleView;

@property (nonatomic, strong) OHSubtitleLabel *subtitleLabel;
@property (nonatomic, assign, getter=isFullScreen, readwrite) BOOL fullscreen;

@end

static const CGFloat kBottomSubtitleConstraintConstant = -40.0;
static const CGFloat kLeftSubtitleConstraintConstant   = 15.0;

@implementation OHSubtitlePlayer {
    __weak UIView *_avUpdatingView;
    
    NSURL *_videoURL;
    CGRect _initialVideoBounds;
    NSMutableDictionary *_subtitlesParts;
    
    NSTimer *_timer;
    NSArray *_vibrancyViews;
    
    IBInspectable NSInteger _fontSize;
    IBInspectable UIColor *_fontColor;
    IBInspectable UIColor *_borderTextColor;
    IBInspectable NSString *_imageViewName;
}

#pragma mark - Getters

- (OHSubtitleLabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[OHSubtitleLabel alloc] init];
        _subtitleLabel.numberOfLines             = 0;
        _subtitleLabel.adjustsFontSizeToFitWidth = YES;
        _subtitleLabel.minimumScaleFactor        = 0.3;
        _subtitleLabel.font          = [UIFont boldSystemFontOfSize:_fontSize ?: 16.0];
        _subtitleLabel.shadowOffset = CGSizeMake(0.0, 0.0);
        _subtitleLabel.textColor     = _fontColor ?: [UIColor whiteColor];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.layer.masksToBounds = NO;
        _subtitleLabel.attributes = @{ NSStrokeWidthAttributeName : @-4.0,
                                       NSStrokeColorAttributeName : _borderTextColor ?: [UIColor blackColor],
                                       NSForegroundColorAttributeName : _subtitleLabel.textColor };
    }
    
    return _subtitleLabel;
}

#pragma mark -

- (void)dealloc {
    [self stopTimer];
    _timer = nil;
    [self removeAllNotifications];
}

- (void)loadViewControllerComponentsWithURL:(NSURL *)videoURL showSubtitleView:(BOOL)showSubtitleView {
    NSParameterAssert(self.viewController && self.view);
    _videoURL = videoURL;
    
    // Initial
    [self loadAVPlayerViewController];
    
    // Observer
    [_avPlayerViewController.player addObserver:self forKeyPath:kRateProperty options:NSKeyValueObservingOptionNew context:kRateContext];
    [_avPlayerViewController.contentOverlayView addObserver:self forKeyPath:kBoundsProperty options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:kBoundsContext];
    [_avPlayerViewController addObserver:self forKeyPath:kVideoBoundsProperty options:0 context:kVideoBoundsContext];
    
    // Top view
    if (showSubtitleView) {
        [self addTopViewInView:_avPlayerViewController.view];
    }
    
    // Subtitle label
    const CGFloat bottom = kBottomSubtitleConstraintConstant;
    [self.subtitleLabel removeConstraints:self.subtitleLabel.constraints];
    [_avPlayerViewController.contentOverlayView plugView:self.subtitleLabel
                                                  bottom:bottom
                                                    left:kLeftSubtitleConstraintConstant
                                                   right:-kLeftSubtitleConstraintConstant];
}

- (void)loadAVPlayerViewController {
    _avPlayerViewController = [AVPlayerViewController new];
    _avPlayerViewController.player = [AVPlayer playerWithURL:_videoURL];
    [self.view plugView:_avPlayerViewController.view];
    
    [self.viewController addChildViewController:_avPlayerViewController];
    [self.view addSubview:_avPlayerViewController.view];
    [_avPlayerViewController didMoveToParentViewController:self.viewController];
    //    self.view.autoresizesSubviews = YES;
}

- (void)loadSubtitleWithContentsOfFile:(NSString *)path {
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self loadSubtitleWithContent:content];
}

- (void)loadSubtitleWithContent:(NSString *)content {
    _subtitlesParts = [NSMutableDictionary dictionary];
    
    [OHSubtitleParser parseString:content subtitles:_subtitlesParts parsed:^(BOOL parsed, NSError *error) {
        if (parsed) {
            [self launchTimer];
        } else {
            _subtitlesParts = nil;
        }
    }];
}

- (void)addTopViewInView:(UIView *)view {
    const CGFloat kHeight = 50.0;
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    UIVisualEffectView *vibrantView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
    
    [view plugView:effectView top:0.0 left:0.0 right:0.0 height:kHeight];
    [view plugView:vibrantView top:0.0 left:0.0 right:0.0 height:kHeight];
    
    _subtitleView = [OHSubtitleView loadViewWithName:NSStringFromClass([OHSubtitleView class]) owner:nil];
    _subtitleView.imageView.image = [UIImage imageNamed:_imageViewName];
    [view plugView:_subtitleView top:0.0 left:0.0 right:0.0 height:kHeight];
    
    _vibrancyViews = @[effectView, vibrantView, _subtitleView];
}

#pragma mark - Timer

- (void)launchTimer {
    [_timer invalidate];
    
    __weak OHSubtitlePlayer *weakSelf = self;
    // Minimum value is 0.1
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:weakSelf selector:@selector(searchAndShowSubtitle) userInfo:nil repeats:YES];
    [_timer fire];
}

// Slow down timer when video is stopped.
- (void)slowDownTimer {
    [_timer invalidate];
    __weak OHSubtitlePlayer *weakSelf = self;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:weakSelf selector:@selector(searchAndShowSubtitle) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - Subtitles

- (void)searchAndShowSubtitle {
    if (!_subtitlesParts.count) {
        self.subtitleLabel.text = @"";
        return ;
    }
    
    const CMTime currentTime = _avPlayerViewController.player.currentItem.currentTime;
    NSNumber *timeInterval = @(currentTime.value/currentTime.timescale ?: 1.0);
    
    NSPredicate *initialPredicate = [NSPredicate predicateWithFormat:@"(%@ >= %K) AND (%@ <= %K)", timeInterval, kStart, timeInterval, kEnd];
    NSArray *subtitles = [_subtitlesParts.allValues filteredArrayUsingPredicate:initialPredicate];
    
    NSMutableString *mutString;
    BOOL hasManyParts = subtitles.count > 1;
    if (hasManyParts) {
        mutString = [NSMutableString new];
        for (NSDictionary *attrStringDict in subtitles) {
            [mutString appendFormat:@"%@\n", attrStringDict[kText]];
        }
    }
    
    self.subtitleLabel.text = hasManyParts ? [mutString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] : subtitles.firstObject[kText];
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == kRateContext) {
        CGFloat rate = [change[NSKeyValueChangeNewKey] floatValue];
        if (rate <= FLT_EPSILON) {
            [self slowDownTimer];
        } else {
            [self stopTimer];
            [self launchTimer];
        }
    } else if (context == kBoundsContext) {
        CGRect oldBounds = [change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newBounds = [change[NSKeyValueChangeNewKey] CGRectValue];
        
        BOOL wasFullscreen = CGRectEqualToRect(oldBounds, [UIScreen mainScreen].bounds);
        BOOL isFullscreen  = CGRectEqualToRect(newBounds, [UIScreen mainScreen].bounds);
        if (isFullscreen && !wasFullscreen) {
            if (CGRectEqualToRect(oldBounds, CGRectMake(0.0, 0.0, newBounds.size.height, newBounds.size.width))) {
                NSLog(@"Rotated fullscreen");
            } else {
                NSLog(@"Entered fullscreen");
                self.fullscreen = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:OHSubtitlePlayerDidEnterFullScreen object:nil];
                });
            }
        } else if (!isFullscreen && wasFullscreen) {
            NSLog(@"Exited fullscreen");
            self.fullscreen = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:OHSubtitlePlayerDidExitFullScreen object:nil];
            });
        }
    } else if (context == kVideoBoundsContext) {
        [self removeObserverForVisibilityProperty];
        UIWindow *mainWindow = [UIApplication sharedApplication].windows.firstObject;
        
        BOOL isFullscreen = NO;
        for (UIView *subview in mainWindow.subviews) {
            if ([subview isKindOfClass:NSClassFromString(kUITransitionView)]) {
                isFullscreen = YES;
            }
        }
        
        isFullscreen ?: [self findAndObserveAVUpdatingViewInView:_avPlayerViewController.view];
    } else if (context == kVisibilityContext) {
        if (![change[NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
            [self showSubtitleViewWithAlpha:((UIView *)object).alpha];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)findAndObserveAVUpdatingViewInView:(UIView *)view {
    Class alphaUpdatingView = NSClassFromString(kAVAlphaUpdatingView);
    for (UIView *subview in view.subviews) {
        if (subview.subviews.count) {
            [self findAndObserveAVUpdatingViewInView:subview];
        }
        
        if ([subview isKindOfClass:alphaUpdatingView]) {
            _avUpdatingView = subview;
            [self showSubtitleViewWithAlpha:subview.alpha];
            [subview addObserver:self forKeyPath:kVisibilityProperty options:NSKeyValueObservingOptionPrior context:kVisibilityContext];
        }
    }
}

- (void)removeAllNotifications {
    [self removeObserverForVisibilityProperty];
    [self removeObserverForRateProperty];
    [self removeObserverForBoundsProperty];
    [self removeObserverForVideoBoundsProperty];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeObserverForVisibilityProperty {
    @try {
        [_avUpdatingView removeObserver:self forKeyPath:kVisibilityProperty];
    } @catch (NSException *exception) { }
}

- (void)removeObserverForRateProperty {
    @try {
        [_avPlayerViewController.player removeObserver:self forKeyPath:kRateProperty];
    } @catch (NSException *exception) { }
}

- (void)removeObserverForBoundsProperty {
    @try {
        [_avPlayerViewController.contentOverlayView removeObserver:self forKeyPath:kBoundsProperty];
    } @catch (NSException *exception) { }
}

- (void)removeObserverForVideoBoundsProperty {
    @try {
        [_avPlayerViewController removeObserver:self forKeyPath:kVideoBoundsProperty];
    } @catch (NSException *exception) { }
}

#pragma mark - Helpers

- (void)showSubtitleViewWithAlpha:(CGFloat)alpha {
    for (UIView *view in _vibrancyViews) {
        view.alpha = alpha;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIView *view in _vibrancyViews) {
            view.hidden = !alpha;
        }
    });
}

- (void)removeSubtitlePlayer {
    [self stopTimer];
    [self removeAllNotifications];
    [self.avPlayerViewController.player pause];
    self.avPlayerViewController.player.rate = 0.0;
    
    [self.avPlayerViewController willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self.avPlayerViewController removeFromParentViewController];
}

@end
