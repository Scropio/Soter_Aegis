//
//  DispatchViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/8.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "DispatchViewController.h"

@interface DispatchViewController ()

@end

@implementation DispatchViewController

@synthesize Source;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    RandomKeyboardViewController *RandomVC = [segue destinationViewController];
    
    RandomVC.Source = Source;
    
}

@end
