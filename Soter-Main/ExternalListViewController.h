//
//  ExternalListViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/7/6.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewElement.h"

#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]

@interface ExternalListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *Table_FileList;

@property (weak, nonatomic) IBOutlet UIView *BottomMenu;

//@property (weak, nonatomic) IBOutlet UIView *BottomSlideMenu;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LoadingIndicator;

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *HomeBtn;
@property (weak, nonatomic) IBOutlet UIView *LoadingMask;
-(NSString *)CombinationPathFromList;
@end
