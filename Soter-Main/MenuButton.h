//
//  MenuButton.h
//  Soter-Main
//
//  Created by Neil on 2015/5/6.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuButton : UIButton

@property (nonatomic) NSString *IconName;
@property (nonatomic) NSString *TitleText;
@property (nonatomic) CGFloat   TitleFontSize;



- (id)initWithFrame:(CGRect)frame IconImageName:(NSString *)icon_image TitleText:(NSString *)title FontSize:(CGFloat)fontsize;


@property (strong,nonatomic) IBOutlet UIImageView* Icon;
@property (strong,nonatomic) IBOutlet UIImageView* TextFrame;
@property (strong,nonatomic) IBOutlet UILabel* Title;
@property (strong,nonatomic) IBOutlet UIImageView* IconMask;
@property (strong,nonatomic) IBOutlet UIImageView* TextFrameMask;



//- (id)initWithFrame:(CGRect)frame Icon:(UIImage*)ICON Title:(NSString *)Text FontSize:(CGFloat)fSize;


//- (void)setICON:(UIImage*)image;
//- (void)setEmptyICON:(UIImage*)image;
//- (void)setTitle:(NSString*)TitleText FontSize:(CGFloat)Size;
//
//- (void)setButtonEnable:(BOOL)Enable;
//- (void)setButtonEnable:(id)target isEnable:(BOOL)Enable;
@end
