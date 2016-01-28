//
//  ExternalFileInfoViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/7/21.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "File.h"
#import "FileBrowserIntegrateTableViewController.h"
#import "Common.h"

@interface ExternalFileInfoViewController : UIViewController

//@property (weak, nonatomic) IBOutlet UILabel *TopLabel;
@property (retain, nonatomic) IBOutlet UIImageView *FileIcon;
@property (weak, nonatomic) IBOutlet UITextView *FileTextView;
//@property (weak, nonatomic) IBOutlet UILabel *FileName;
@property (weak, nonatomic) IBOutlet UIView *BottomBarMenu;

@property (weak,nonatomic) File *CurrentFile;
@property (weak,nonatomic) NSData *OTGFile;

//@property (weak, nonatomic) IBOutlet UILabel *FileSize;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ActionButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LoadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *LoadingMask;
@property (weak, nonatomic) IBOutlet UIButton *EncryptBtn;

@end
