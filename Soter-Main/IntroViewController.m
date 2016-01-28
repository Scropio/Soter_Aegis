//
//  IntroViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/20.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "IntroViewController.h"
#import "Language.h"
#import "LanguageViewController.h"
@interface IntroViewController ()

@end

@implementation IntroViewController

static float sHeight;
static float sWidth;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sHeight = [[UIScreen mainScreen] bounds].size.height;
    sWidth  = [[UIScreen mainScreen] bounds].size.width;
    
    float x_Padding = (sWidth - 84 - 205 - 10)/2;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

    UIImageView *Logo = [[UIImageView alloc] initWithFrame:CGRectMake(x_Padding,x_Padding,84,84)];
    Logo.layer.cornerRadius = 10;
    Logo.clipsToBounds = YES;
    Logo.image = [UIImage imageNamed:@"APP"];
    
    UILabel *Header = [[UILabel alloc] initWithFrame:CGRectMake(sWidth-x_Padding-205+5, x_Padding+12, 205, 50)];
    //Header.text = @"Soter Aegis";
    Header.text = [Language get:@"About_Header" alter:@"Soter Aegis"];


    Header.font = [UIFont systemFontOfSize:40];
    
    UILabel *Version = [[UILabel alloc] initWithFrame:CGRectMake(sWidth-x_Padding-150, x_Padding+62, 250, 30)];
    Version.text = @"Version ver 1.0.0.0";
    Version.font = [UIFont systemFontOfSize:18];
    
    UILabel *Content = [[UILabel alloc] initWithFrame:CGRectMake(x_Padding, x_Padding+92 , sWidth-2*x_Padding, sHeight - 66 - x_Padding*2 - 102)];
//    Content.text = @"Soter Aegis is a portable data management tools which support the twin systems-iOS/Windows.It helped user to open, remove, reserve on the cloud storage and encrypt the data in the Flash with AES 256. You also can decrypt and open the cryptic privacy data by connect the Soter Aegis APP with your iOS device to meet the data safety management function. And one more thing:It also has passed the Apple MFi certification.";
        Content.text = [Language get:@"About_Text" alter:@"About_Text"];
    Content.numberOfLines = 0;
    Content.font = [UIFont systemFontOfSize:20];
    Content.textAlignment = NSTextAlignmentCenter;

    //    Content.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:Header];
    [self.view addSubview:Logo];
    [self.view addSubview:Version];
    [self.view addSubview:Content];
}

-(void)viewWillAppear:(BOOL)animated{
    [self UpdateData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark update data
-(void)UpdateData
{
    self.title = [Language get:@"About_Title" alter:@"About Seoter Aegis"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"About_Title" alter:@"About Seoter Aegis"];

}

@end
