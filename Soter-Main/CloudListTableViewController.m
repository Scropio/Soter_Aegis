//
//  CloudListTableViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/20.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "CloudListTableViewController.h"
#import "Language.h"
#import "LanguageViewController.h"

@interface CloudListTableViewController ()

@end

@implementation CloudListTableViewController

@synthesize HomeBtn;

static NSArray *clouds;
static NSString *Identifier;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    clouds = [NSArray arrayWithObjects:@"Dropbox", nil];
    Identifier = @"CloudCell";
    
//    self.CloudList.backgroundColor = [UIColor clearColor];
    
//    UIImageView *ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Curtain"]];
//    [ImageView setFrame:self.CloudList.frame];
//    
//    self.CloudList.backgroundView = ImageView;
    
    if(![Common CheckInternet])
    {
        UIAlertView *ErrorMsg;
        
        ErrorMsg = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                              message:[Language get:@"Cloud_error_msg2" alter:@"Please check your internet service\n and try again"]
                                             delegate:self
                                    cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                    otherButtonTitles:nil];
        
        [ErrorMsg show];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Curtain"]];
    
    [HomeBtn setImage:[[UIImage imageNamed:@"home.png"]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [self UpdateData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return clouds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if(Cell == nil)
    {
        Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    //設定Selected的背景色
//    UIView *bgView = [[UIView alloc]init];
////    bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:255 alpha:0.3];
//    [Cell setSelectedBackgroundView:bgView];
//    Cell.backgroundColor = [UIColor clearColor];
    
    UIImageView *Logo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 64, 64)];
    
    UILabel *Title = [[UILabel alloc] initWithFrame:CGRectMake(84, 22, 250, 40)];
    
    NSLog(@"%@",clouds[indexPath.row]);
    
    if ([clouds[indexPath.row]  isEqual: @"GoogleDrive"])
    {
        [Logo setImage:[UIImage imageNamed:@"Google_Icon" ]];
        Title.text = @"Google";
        Title.font = [UIFont systemFontOfSize:30];
        
    }
    else if ([clouds[indexPath.row] isEqual: @"Dropbox"])
    {
        [Logo setImage:[UIImage imageNamed:@"Dropbox_Icon" ]];
        Title.text = @"Dropbox";
        Title.font = [UIFont systemFontOfSize:30];
    }
    
    [Cell addSubview:Logo];
    [Cell addSubview:Title];
    
    return Cell;
}

//UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"CloudList2FileList" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (IBAction)HomeBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    self.title = [Language get:@"Cloud_Title" alter:@"Cloud List"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"Cloud_Title" alter:@"Cloud List"];
    
    
    
}

@end
