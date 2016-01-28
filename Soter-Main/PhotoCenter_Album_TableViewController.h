//
//  PhotoCenter_Album_TableViewController.h
//  Soter
//
//  Created by Neil on 2015/4/23.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoCenter_Album_TableViewController : UITableViewController

//From previous view
@property (nonatomic, strong) ALAssetsGroup *photoGroup;

@property (strong, nonatomic)   IBOutlet UITableView        *Table_AlbumList;
@property (weak, nonatomic)     IBOutlet UIBarButtonItem    *HomeBtn;

@end
