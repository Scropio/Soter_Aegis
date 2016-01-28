//
//  ViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/5/6.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuButton.h"
#import "MainViewElement.h"
#import "RandomKeyboardViewController.h"
#import "FileSystemAPI.h"
#import <iFDiskSDK_iap2/iFDiskSDK_iap2.h>

@interface ViewController : UIViewController


@property (strong) MenuButton *Menu_A;
@property (strong) MenuButton *Menu_B;
@property (strong) MenuButton *Menu_C;
@property (strong) MenuButton *Menu_D;
@property (strong) MenuButton *Menu_E;


@property (weak, nonatomic) IBOutlet UILabel *AvailableSpace;
@property (weak, nonatomic) IBOutlet UIButton *GetAvailable;

@property (strong, nonatomic) IBOutlet MainViewElement *mElement;


@end

