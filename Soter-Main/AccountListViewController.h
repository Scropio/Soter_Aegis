//
//  AccountListViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/5/13.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface AccountListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *AccountListTableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *HomeBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *AddBtn;

//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;



@end
