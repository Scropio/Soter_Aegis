//
//  FileBrowserIntegrateTableViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/9/8.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>

#import <DropboxSDK/DropboxSDK.h>

#import "FileSystemAPI.h"
#import "File.h"
#import "FileType.h"

#import "FileTableViewCell.h"

#import "Common.h"

@interface FileBrowserIntegrateTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *TagetBrowserTableView;

// OTG = 1 | CLOUD = 2 | PHOTO = 3
@property (nonatomic) int Source;

// OTG = 1 | CLOUD = 2 | PHOTO = 3
@property (nonatomic) int Target;

// Move = 1 | Copy = 2
@property (nonatomic) int Action;

//Full file path array
@property (nonatomic) NSMutableArray *TargetFiles;

@end
