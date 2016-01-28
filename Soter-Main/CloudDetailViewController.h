//
//  CloudDetailViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/5/21.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "File.h"
#import <DropboxSDK/DropboxSDK.h>
#import "RDActionSheet.h"
#import "Common.h"
#import "FileSystemAPI.h"
#import "FileBrowserIntegrateTableViewController.h"

@interface CloudDetailViewController : UIViewController

@property (weak, nonatomic) UIImage *FileThumbnail;

@property (weak, nonatomic) IBOutlet UIImageView *Thumbnail;
//@property (weak, nonatomic) IBOutlet UILabel *FileName;

@property (weak, nonatomic) IBOutlet UITextView *Content_TextView;
@property (weak, nonatomic) IBOutlet UIView *BottomBarMenu;

@property (weak, nonatomic) File *CurrentFile;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LodingIndicator;
@property (weak, nonatomic) IBOutlet UIProgressView *UploadProgress;

@end
