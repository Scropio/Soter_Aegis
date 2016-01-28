//
//  AccountListViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/13.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "AccountListViewController.h"
#import "AccountEditViewController.h"
#import "AccountTableViewCell.h"
#import "Database.h"
#import "Account.h"
#import "Language.h"
#import "LanguageViewController.h"


@interface AccountListViewController ()
{
    Database *db;
    
    Account *SelectAccount;
    NSMutableArray *AccountList;
    
    NSArray *result;
    
    float sHeight;
}
@end

@implementation AccountListViewController

@synthesize AccountListTableView;
@synthesize HomeBtn,AddBtn;

static NSString *AccountCellIdentifier = @"AccountTableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"H:%lf   W:%lf",self.view.frame.size.height,self.view.frame.size.width);
    
    
    [self.AccountListTableView registerNib:[UINib nibWithNibName:@"AccountCellView"
                                                          bundle:nil]
                    forCellReuseIdentifier:AccountCellIdentifier];
    
//    sHeight = self.AccountListTableView.frame.size.height/5;
    
    NSLog(@"ViewDidLoad:%f",sHeight);
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    db = [[Database alloc]init];
    
//    [db open];
    
    [HomeBtn setImage:[[UIImage imageNamed:@"home.png"]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [AddBtn setImage:[[UIImage imageNamed:@"add.png"]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

//    result = [db selectData];
    
//    if(result.count > 0)
//    {
//        NSString *Username = ((Account*)result[0]).Username;
//    }
    
//    UIImageView *ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Curtain"]];
//    [ImageView setFrame:self.AccountListTableView.frame];
//    
//    self.AccountListTableView.backgroundView = ImageView;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
//    [db close];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self UpdateData];

    [db open];
    
    result = [db selectData];
    
    [db close];
    
    [self.AccountListTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [result count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    sHeight = self.view.frame.size.height/10;
    
    return sHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Account *current = (Account*)result[indexPath.row];
    
    AccountTableViewCell *Cell = (AccountTableViewCell *)[tableView dequeueReusableCellWithIdentifier:AccountCellIdentifier];
    
    if (Cell == nil)
    {
        Cell = [[AccountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:AccountCellIdentifier];
        
        Cell.Image_Thumbnail.frame = CGRectMake(20, 4, sHeight - 8, sHeight - 8);
    
        NSLog(@"Image H:%lf ",Cell.Image_Thumbnail.frame.size.height);
    
        Cell.Label_Title_Username.frame = CGRectMake(Cell.Image_Thumbnail.frame.size.width + 8,
                                                     sHeight*2/3,
                                                     96,
                                                     24);
    
        [Cell.Label_Username setFrame:CGRectMake(Cell.Label_Title_Username.frame.origin.x + 4,
                                                 sHeight*2/3,
                                                 192,
                                                 24)];
    
        Cell.Label_Title_Comment.frame = CGRectMake(Cell.Label_Title_Username.frame.origin.x,
                                                    sHeight/3,
                                                    96,
                                                    24);
    
        [Cell.Label_Comment setFrame:CGRectMake(Cell.Label_Username.frame.origin.x,
                                                sHeight/3,
                                                192,
                                                24)];
    
        [Cell.Label_Comment setFrame:CGRectMake(Cell.Label_Username.frame.origin.x,
                                                sHeight/3,
                                                192,
                                                24)];
    }
    
//    [Cell.Image_Thumbnail setBackgroundColor:[UIColor blueColor]];
    
    NSLog(@"Service.Name=%@",current.Name);
    NSLog(@"Account.ID = '%@'",current.ID);
    
    [Cell.Image_Thumbnail setImage:[UIImage imageNamed:[Common ServiceMapping:current.Name]]];
    Cell.Image_Thumbnail.contentMode = UIViewContentModeScaleAspectFit;
    
//    Cell.Image_Thumbnail.contentMode = UIViewContentModeCenter;
//    [Cell setBackgroundColor:[UIColor redColor]];
    
//    if (Cell == nil)
//    {
//        Cell = [[AccountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                           reuseIdentifier:AccountCellIdentifier];
//    }
    
//    NSLog(@"RectMake:%f",Cell.frame.size.height);
    
    NSLog(@"sHeight:%f",sHeight);
    
    [Cell.Label_Username setText:current.Username];
    
    [Cell.Label_Comment setText:current.Comment];

    return Cell;
}

//UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectAccount = (Account*)result[indexPath.row];
    
    [self performSegueWithIdentifier:@"Account2Detail" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    UINavigationController *AccountEditView = segue.;
    
//    UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
    AccountEditViewController *accountViewController = (AccountEditViewController*)[segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"Account2Detail"])
    {
//        AccountEditView.CurrentAccount = SelectAccount;
        accountViewController.CurrentAccount = SelectAccount;
//        [accountViewController setCurrentAccount:SelectAccount];
        
//        [AccountEditView setCurrentAccount:SelectAccount];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 100);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)   tableView:(UITableView *)tableView
  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
   forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Account* delAccount = (Account*)result[indexPath.row];
        
        [db open];
            [db deleteData:delAccount.ID];
            result = [db selectData];
        [db close];
        
        [self.AccountListTableView reloadData];
    }
}

- (IBAction)HomeBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)AddBtnClick:(id)sender {
    
}



#pragma mark update data
-(void)UpdateData
{
    self.title = [Language get:@"AccountManager_Title" alter:@"Account Manager"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"AccountManager_Title" alter:@"Account Manager"];
    
    

    
}


@end
