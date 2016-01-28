//
//  SettingManagerViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/5/20.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileSystemAPI.h"
#import <iFDiskSDK_iap2/iFDiskSDK_iap2.h>

@interface SettingManagerViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *OptionList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *HomeBtn;

@property (nonatomic) UILabel *CapacityText;

//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
