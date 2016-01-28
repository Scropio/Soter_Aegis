//
//  CloudListTableViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/5/20.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface CloudListTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *CloudList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *HomeBtn;

@end
