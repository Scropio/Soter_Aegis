//
//  PhotoCenter_Photo_CollectionViewController.h
//  Soter
//
//  Created by Neil on 2015/4/23.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoCollectionViewCell.h"
#import "RDActionSheet.h"
#import "FileSystemAPI.h"
#import "Common.h"

//Target ViewController
#import "FileBrowserIntegrateTableViewController.h"

@interface PhotoCenter_Photo_CollectionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *Collect_Photo;
@property (weak, nonatomic) IBOutlet UIView *BottomBarMenu;

@property (nonatomic, strong) ALAssetsGroup *photoGroup;
@property (nonatomic, copy) NSString *galleryTitle;

@end
