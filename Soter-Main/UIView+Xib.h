//  Created by Oleg on 2015.
//  Copyright (c) 2015 Oleg Hnidets. All rights reserved.
//

@import UIKit;

@interface UIView (Xib)

- (void)loadNibFile;
- (void)plugView:(UIView *)view;
- (void)plugView:(UIView *)view bottom:(CGFloat)bottom left:(CGFloat)left right:(CGFloat)right;
- (void)plugView:(UIView *)view top:(CGFloat)top left:(CGFloat)left right:(CGFloat)right height:(CGFloat)height;

+ (instancetype)loadViewWithName:(NSString *)nibName owner:(id)owner;
- (instancetype)loadViewWithName:(NSString *)nibName;

@end
