//
//  CloudLoginViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/6/22.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "CloudLoginViewController.h"
#import "Language.h"
#import "LanguageViewController.h"

@interface CloudLoginViewController () <DBRestClientDelegate>
{
    DBRestClient *restClient;
    Boolean Coming;
}
@end

static int PageCount = 0;

@implementation CloudLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"%@",[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2]);
    
    if(![Common CheckInternet])
    {
        UIAlertView *ErrorMsg;
        
        ErrorMsg = [[UIAlertView alloc] initWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                              message:[Language get:@"Cloud_error_msg2" alter:@"Please check your internet service\n and try again"]
                                             delegate:self
                                    cancelButtonTitle:[Language get:@"PhotoCenter_OK" alter:@"OK"]
                                    otherButtonTitles:nil];
        
        [ErrorMsg show];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (PageCount % 2 == 0)
    {
        if ([[DBSession sharedSession] isLinked])
        {
            [self performSegueWithIdentifier:@"CloudAuth2FileList" sender:self];
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    PageCount += 1;
    
    NSLog(@"PageCount:%d",PageCount);
}

- (IBAction)btnLoginClick:(id)sender {
    if (![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"Dropbox Re-linked");
    }
    else
    {
        [self performSegueWithIdentifier:@"CloudAuth2FileList" sender:self];
        NSLog(@"Dropbox is Linked");
    }
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

@end
