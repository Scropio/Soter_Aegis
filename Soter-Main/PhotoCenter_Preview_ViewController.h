//
//  PhotoCenter_Preview_ViewController.h
//  Soter
//
//  Created by Neil on 2015/4/23.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <DropboxSDK/DropboxSDK.h>
#import "Common.h"

@interface PhotoCenter_Preview_ViewController : UIViewController
//- (id)initWithPhotos:(NSArray *)photos atIndexPath:(NSIndexPath *)indexPath forCollectionViewLayout:(UICollectionViewLayout *)layout;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *UploadIndicator;
@property (nonatomic,copy) NSString  *PhotoName;

@property (nonatomic,copy) UIImage   *PreviewPhoto;

@property (nonatomic,strong) ALAsset *PhotoAsset;

@property (nonatomic,strong) IBOutlet UIImageView *FullPhoto;

@property (weak, nonatomic) IBOutlet UIView *BottomBarMenu;

@property (weak, nonatomic) IBOutlet UIProgressView *UploadProgress;

@property (weak, nonatomic) IBOutlet UIButton *Encrypt_Btn;
@property (weak, nonatomic) IBOutlet UIButton *Move_Btn;
@property (weak, nonatomic) IBOutlet UIButton *Copy_Btn;
@property (weak, nonatomic) IBOutlet UIButton *Del_Btn;



@end
