//  Created by Oleg on 2015.
//  Copyright (c) 2015 Oleg Hnidets. All rights reserved.
//

#import "UIView+Xib.h"

@implementation UIView (Xib)

+ (instancetype)loadViewWithName:(NSString *)nibName owner:(id)owner {
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    return [nib instantiateWithOwner:owner options:nil].firstObject;
}

- (instancetype)loadViewWithName:(NSString *)nibName {
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    return [nib instantiateWithOwner:self options:nil].firstObject;
}

- (void)loadNibFile {
    UIView *view = [self loadViewWithName:NSStringFromClass([self class])];
    [self plugView:view];
}

- (void)plugView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeBottom constant:0.0]];
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeTop constant:0.0]];
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeLeft constant:0.0]];
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeRight constant:0.0]];
}


- (void)plugView:(UIView *)view bottom:(CGFloat)bottom left:(CGFloat)left right:(CGFloat)right {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeBottom constant:bottom]];
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeLeft constant:left]];
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeRight constant:right]];
}

- (void)plugView:(UIView *)view top:(CGFloat)top left:(CGFloat)left right:(CGFloat)right height:(CGFloat)height {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeTop constant:top]];
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeLeft constant:left]];
    [self addConstraint:[self constraintWitItem:view attribute:NSLayoutAttributeRight constant:right]];
    
    [view addConstraint:[view heightConstraintWithConstant:height]];
}

#pragma mark - Constraints

- (NSLayoutConstraint *)widthConstraintWithConstant:(CGFloat)width {
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:0.0
                                         constant:width];
}

- (NSLayoutConstraint *)heightConstraintWithConstant:(CGFloat)height {
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:0.0
                                         constant:height];
}

- (NSLayoutConstraint *)constraintWitItem:(UIView *)view attribute:(NSLayoutAttribute)attribute constant:(CGFloat)constant {
    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:constant];
}

@end
