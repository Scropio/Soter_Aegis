//  Created by Oleg on 2015.
//  Copyright (c) 2015 Oleg Hnidets. All rights reserved.
//

@import UIKit;
@import AVKit;
@import AVFoundation;
#import "OHSubtitleView.h"

extern NSString *_Nonnull const OHSubtitlePlayerDidEnterFullScreen;
extern NSString *_Nonnull const OHSubtitlePlayerDidExitFullScreen;

IB_DESIGNABLE
//! A player controller displays the video content.
@interface OHSubtitlePlayer : NSObject

@property (nonatomic, strong, readonly, nonnull) AVPlayerViewController *avPlayerViewController;
@property (nonatomic, strong, readonly, nullable) OHSubtitleView *subtitleView;

@property (nonatomic, weak, nullable) IBOutlet UIViewController *viewController;
@property (nonatomic, weak, nullable) IBOutlet UIView *view;

@property (nonatomic, assign, getter=isFullScreen, readonly) BOOL fullscreen;

- (void)loadViewControllerComponentsWithURL:(nonnull NSURL *)videoURL showSubtitleView:(BOOL)showSubtitleView;
- (void)loadSubtitleWithContentsOfFile:(nullable NSString *)path;
- (void)loadSubtitleWithContent:(nullable NSString *)content;

- (void)removeSubtitlePlayer;

@end
