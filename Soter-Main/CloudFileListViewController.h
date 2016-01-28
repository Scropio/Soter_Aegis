//
//  CloudFileListViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/9/18.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "Common.h"

#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]

@interface CloudFileListViewController : UIViewController < DBRestClientDelegate,
                                                            UITableViewDataSource,
                                                            UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *CloudFileList;

@end
