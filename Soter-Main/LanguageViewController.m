//
//  LanguageViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/20.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "LanguageViewController.h"
#import "Language.h"

@interface LanguageViewController ()

@end

@implementation LanguageViewController


static NSArray *Languages;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Languages = [NSArray arrayWithObjects:@"English", @"繁體中文",@"简体中文",nil];
    
    self.LanguageList.backgroundColor = [UIColor clearColor];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}
//--hemly
- (void)viewWillAppear:(BOOL)animated {
    self.title = [Language get:@"Language_setting" alter:@"Language Setting"];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}
//--end

//UITableViewDataSource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return Languages.count;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    UITableViewCell *Cell = [[UITableViewCell alloc]init];
    //
    //    Cell.accessoryType = UITableViewCellAccessoryNone;
    //    Cell.backgroundColor = [UIColor clearColor];
    //
    //    //設定Selected的背景色
    //    UIView *bgView = [[UIView alloc]init];
    //    bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:255 alpha:0.3];
    //    [Cell setSelectedBackgroundView:bgView];
    //
    //    //Title
    //    UILabel *Title = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 250, 44)];
    //    Title.text = Languages[indexPath.row];
    //    Title.font = [UIFont systemFontOfSize:30];
    //    [Cell addSubview:Title];
    //
    //    return Cell;
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [Languages objectAtIndex:indexPath.row];
    
    // Current Language
    NSString *lang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    
    //    if ([lang isEqualToString:@"zh-Hans"]) {  // If Simple Chinise
    ////        if (indexPath.row == 0) {
    //            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    ////        }
    //    }
    //    else if ([lang isEqualToString:@"zh-Hant"])
    //    {  // If English
    ////        if (indexPath.row == 2) {
    //            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    ////        }
    //    }
    //    else{  // If English
    ////        if (indexPath.row == 1) {
    //            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    ////        }
    //    }
    //
    //
    //
    
    
    switch (indexPath.row) {
        case 0:
            if([lang isEqualToString:@"en"])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 1:
            if([lang isEqualToString:@"zh-Hant"])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }            break;
        case 2:
            if([lang isEqualToString:@"zh-Hans"])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
            
        default:
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
    }
    
    
    return cell;
    
}

//UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects: @"en",@"zh-Hant",@"zh-Hans", nil]
                                                      forKey:@"AppleLanguages"];
            [Language setLanguage:@"en"];
            break;
        }
        case 1:
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-Hant",@"en", @"zh-Hans", nil]
                                                      forKey:@"AppleLanguages"];
            [Language setLanguage:@"zh-Hant"];
            break;
        }
        case 2:
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-Hans", @"zh-Hant", @"en",nil]
                                                      forKey:@"AppleLanguages"];
            [Language setLanguage:@"zh-Hans"];
            break;
        }
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.title = [Language get:@"Language_setting" alter:@"Language Setting"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"setting" alter:@"Setting"];
    
    [tableView reloadData];}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    [self.LanguageList cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.LanguageList cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    return indexPath;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
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
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    NSLog(@"Exit Exit");
}

@end
