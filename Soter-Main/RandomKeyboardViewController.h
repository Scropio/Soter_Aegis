//
//  RandomKeyboardViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/5/7.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RandomKeyboardViewController : UIViewController

@property (nonatomic,strong) NSString *Source;
@property (weak, nonatomic) IBOutlet UIButton *Home;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *HomeBtn;

@end
