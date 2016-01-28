//
//  SettingManagerViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/20.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "SettingManagerViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Reachability.h"
#import "Language.h"
#import "LanguageViewController.h"

@protocol SwitchDelegate
- (void)valueChangeNotify:(id)sender;
@end

@interface SettingManagerViewController ()
{
    id<SwitchDelegate> delegate;
    
    FileSystemAPI *fsaAPI;
    
    NSArray *nsaProtocolString;
    NSMutableArray *nsmaAccessoryList;
    
    EADSessionController *escSessionController;
    OTAController *OTAISP;
    
    UILabel *AvailableSpace;
    
}
@end

@implementation SettingManagerViewController

@synthesize HomeBtn;
@synthesize CapacityText;

static float sHeight;
static float sWidth;
//--------------------
UILabel * Finded_Label_Name,*Finded_Label_Name2;
UILabel *Label_Name ;
UITableViewCell *Cell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    sHeight = [[UIScreen mainScreen] bounds].size.height;
    sWidth  = [[UIScreen mainScreen] bounds].size.width;
    
    self.OptionList.backgroundColor = [UIColor clearColor];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    //
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(accessoryDidConnect:)
    //                                                 name:EAAccessoryDidConnectNotification object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(accessoryDidDisconnect:)
    //                                                 name:EAAccessoryDidDisconnectNotification object:nil];
    
    //    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    //
    
    if([nsmaAccessoryList count] != 0)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            //        dispatch_async(dispatch_get_main_queue(),^{
            [self changeViewInitOTG];
            [self UpdateAvialable];
        });
    }
    
    [HomeBtn setImage:[[UIImage imageNamed:@"home.png"]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //    if([self CheckInternet])
    //    {
    //    }
    //
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    [self UpdateData];

    //    Label_Name.text = [Language get:@"Setting_Option1" alter:@"Setting_Option1"];
    //    Label_Name.text = [Language get:@"Setting_Option2" alter:@"Setting_Option1"];
    //    Label_Name.text = [Language get:@"Setting_Option3" alter:@"Setting_Option1"];
    //    Label_Name.text = [Language get:@"Setting_Option4" alter:@"Setting_Option1"];
    //    Label_Name.text = [Language get:@"Setting_Option5" alter:@"Setting_Option1"];
    // UIView *subviews  = [self.view Label_Name.tag:1];
    
    //
    //    UIView *subviews  = [self.view viewWithTag:2];
    //    UIView *subviews  = [self.view viewWithTag:3];
    //    UIView *subviews  = [self.view viewWithTag:4];
    //    UIView *subviews  = [self.view viewWithTag:5];
    //    for (UIView *subviews in [self.view subviews]) {
    //        if (subviews.tag==1) {
    //            UIView *subviews  = [self.view viewWithTag:1];
    //            [subviews removeFromSuperview];
    //        }
    //    }
    
    // [subviews removeFromSuperview];
    self.title = [Language get:@"Setting_Title" alter:@"Setting"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"Setting_Title" alter:@"Setting"];
    [self.tableView reloadData];
    
}

- (void)changeViewInitOTG
{
    if(fsaAPI == nil){
        fsaAPI = [[FileSystemAPI alloc] init:self];
        fsaAPI.delegateForAPI = self;
    }
}

- (void)UpdateAvialable
{
    uint64_t space = [fsaAPI getAvailableSpace];
    uint64_t usage = [fsaAPI totalAvailableSpace];
    
    dispatch_async(dispatch_get_main_queue(),^{
        CapacityText.text = [NSString stringWithFormat:@"%.02lf%%",((double)space/(double)usage)*100];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    //    if(Cell == nil)
    //    {
    //        Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //    }
    
    
    //   static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    //    // Configure the cell...
    //    if (Cell == nil) {
    //      //  Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //
    //      //  Cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    //        Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CellIdentifier] ;
    //        Cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //        Cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //    }
    //
    // Cell.textLabel.text = [Language get:@"Language_setting" alter:@"Language Setting"];
    //******************
    //cell的標飾符
    static NSString *CellIdentifier = @"cellIdentifier";
    
    //指定tableView可以重用cell，增加性能，不用每次都alloc新的cell object
    Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    UILabel * Finded_Label_Name,*Finded_Label_Name2;
//    UILabel *Label_Name ;
    
    // Label_Name.font = [UIFont systemFontOfSize:20];
    //如果cell不存在，從預設的UITableViewCell Class裡alloc一個Cell object，應用Default樣式，你可以修改為其他樣式
    if (Cell == nil) {
        Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        Label_Name = [[UILabel alloc]initWithFrame:CGRectMake(84, 10, 240, 64)];
        //    [Cell setTintColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:0.4]];
        
        UIView *bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:255 alpha:0.2];
        //    bgView.backgroundColor = [UIColor clearColor];
        [Cell setSelectedBackgroundView:bgView];
        
        Label_Name.font = [UIFont systemFontOfSize:20];
        
        Cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *SystemICON = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 64 , 64)];
        
        UIImageView *DetailICON = [[UIImageView alloc] initWithFrame:CGRectMake(sWidth - 30 - 5, 22, 30 , 40)];
        
        UISwitch * DropboxLogout = [[UISwitch alloc] initWithFrame:CGRectZero];
        
        switch (indexPath.row)
        {
            case 0:
                //   Label_Name.text = @"Super Password";
                Label_Name.text = [Language get:@"Setting_Option1" alter:@"Setting_Option1"];
                
               // [Language get:@"Setting_Option1" alter:@"Setting_Option2"]
                Label_Name.tag = 11;
                // UILabel *La1 = [[UILabel alloc] viewWithTag:11];
                //  UILabel *La1 = [UILabel tag:11];
                
                
                [SystemICON setImage:[UIImage imageNamed:@"ic_keyboard_button"]];
                [DetailICON setImage:[UIImage imageNamed:@"Next_button"]];
                Cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [Cell addSubview:DetailICON];
                break;
                
            case 1:
                Label_Name.tag = 12;
                // Label_Name.text = @"Dropbox logout";
                Label_Name.text = [Language get:@"Setting_Option2" alter:@"Setting_Option2"];
                
                [SystemICON setImage:[UIImage imageNamed:@"Dropbox_Logout"]];
                
                SystemICON.contentMode = UIViewContentModeScaleAspectFit;
                
                //            [DropboxLogout setFrame:CGRectMake(sWidth-DropboxLogout.frame.size.width-10,
                //                                               (84 - DropboxLogout.frame.size.height)/2,
                //                                               DropboxLogout.frame.size.width,
                //                                               DropboxLogout.frame.size.height)];
                //
                //            [DropboxLogout addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
                //
                if ([[DBSession sharedSession] isLinked])
                {
                    [DropboxLogout setOn:YES];
                }
                else
                {
                    [DropboxLogout setOn:NO];
                }
                
                //            [Cell addSubview:DropboxLogout];
                break;
                
            case 2:
                Label_Name.tag = 13;
                // Label_Name.text = @"About Soter";
                Label_Name.text = [Language get:@"Setting_Option3" alter:@"Setting_Option3"];
                
                [SystemICON setImage:[UIImage imageNamed:@"ic_no_soter_aegis_button"]];
                [DetailICON setImage:[UIImage imageNamed:@"Next_button"]];
                Cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [Cell addSubview:DetailICON];
                break;
            case 3:
                Label_Name.tag = 14;
                //  Label_Name.text = @"Capacity";
                Label_Name.text = [Language get:@"Setting_Option4" alter:@"Setting_Option4"];
                
                [SystemICON setImage:[UIImage imageNamed:@"aviableSpace"]];
                
                CapacityText = [[UILabel alloc] initWithFrame:CGRectMake(180,10,264,64)];
                //CapacityText.text = @"No device";
                CapacityText.tag = 16;
                CapacityText.text = [Language get:@"Setting_msg1" alter:@"Setting_msg1"];
       
                [Cell addSubview:CapacityText];
                
                //            [DetailICON setImage:[UIImage imageNamed:@"Next_button"]];
                //            Cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                //            [Cell addSubview:DetailICON];
                break;
            case 4:
                Label_Name.tag = 15;
                // Label_Name.text = @"Language";
                Label_Name.text = [Language get:@"Setting_Option5" alter:@"Setting_Option5"];
      
                [SystemICON setImage:[UIImage imageNamed:@"ic_no_soter_aegis_button"]];
                [DetailICON setImage:[UIImage imageNamed:@"Next_button"]];
                Cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [Cell addSubview:DetailICON];
                break;
            case 5:
                Label_Name.tag = 15;
                // Label_Name.text = @"Language";
                Label_Name.text = [Language get:@"Setting_Option5" alter:@"Setting_Option5"];
                
                [SystemICON setImage:[UIImage imageNamed:@"ic_no_soter_aegis_button"]];
                [DetailICON setImage:[UIImage imageNamed:@"Next_button"]];
                Cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [Cell addSubview:DetailICON];
                break;
                
        }
        [Cell addSubview:Label_Name];
        [Cell addSubview:SystemICON];
    }
    else{
  
        NSLog(@"Label_Name: %ld", (long)Label_Name.tag);
        
        
        switch (indexPath.row) {
            case 0:
                Finded_Label_Name = (UILabel*) [Cell viewWithTag:11];
                Finded_Label_Name.text = [Language get:@"Setting_Option1" alter:@"Setting_Option1"];
                break;
            case 1:
                Finded_Label_Name = (UILabel*) [Cell viewWithTag:12];
                Finded_Label_Name.text = [Language get:@"Setting_Option2" alter:@"Setting_Option2"];
                break;
            case 2:
                Finded_Label_Name = (UILabel*) [Cell viewWithTag:13];
                Finded_Label_Name.text = [Language get:@"Setting_Option3" alter:@"Setting_Option3"];
                break;
            case 3:
                Finded_Label_Name = (UILabel*) [Cell viewWithTag:14];
                Finded_Label_Name.text = [Language get:@"Setting_Option4" alter:@"Setting_Option4"];
                Finded_Label_Name2 = (UILabel*) [Cell viewWithTag:16];
                Finded_Label_Name2.text = [Language get:@"Setting_msg1" alter:@"Setting_msg1"];
                break;
            case 4:
                Finded_Label_Name = (UILabel*) [Cell viewWithTag:15];
                Finded_Label_Name.text = [Language get:@"Setting_Option5" alter:@"Setting_Option5"];
                
                // Setting_msg1 = "No device";
                break;
            case 5:
                Finded_Label_Name = (UILabel*) [Cell viewWithTag:15];
                Finded_Label_Name.text = [Language get:@"Setting_Option5" alter:@"Setting_Option5"];
                break;

                
            default:
                break;
        }
        
    }

    return Cell;
}
NSString *CellIdentifier = @"SettingCell";
//UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"Setting2Super" sender:self];
            break;
            
        case 1:
            if ([[DBSession sharedSession] isLinked])
            {
                [[DBSession sharedSession] unlinkAll];
                
              //  UIAlertView *MessageView = [[UIAlertView alloc] initWithTitle:@"System" message:@"Dropbox is already logout" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
               // [Language get:@"Setting_AlertView_msg3" alter:@"OK"]
                UIAlertView *MessageView = [[UIAlertView alloc] initWithTitle:[Language get:@"Setting_AlertView_msg1" alter:@"System"]message:[Language get:@"Setting_AlertView_msg2" alter:@"Dropbox is already logout"]delegate:self cancelButtonTitle:[Language get:@"Setting_AlertView_msg3" alter:@"OK"] otherButtonTitles:nil];
                [MessageView show];
            }
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"Setting2Intro" sender:self];
            break;
        case 4:
            [self performSegueWithIdentifier:@"Setting2Lang" sender:self];
            break;
        case 5:
            [self performSegueWithIdentifier:@"videoa" sender:self];
            break;
            
        default:
            
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

-(void)valueChange:(id)sender
{
    [delegate valueChangeNotify:sender];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
- (IBAction)HomeBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - OTG
//The iFDisk did connect
- (void)accessoryDidConnect:(NSNotification *)notification
{
    
    [escSessionController closeSession];
    [escSessionController setupControllerForAccessory:nil withProtocolString:nil];
    fsaAPI = nil;
    OTAISP = nil;
    
    EAAccessory	*eaaConnect = [[notification userInfo] objectForKey:EAAccessoryKey];
    NSArray	*nsaPSfromDevice = [eaaConnect protocolStrings];
    
    for(NSString *nssPSfromDevice in nsaPSfromDevice){
        
        for(NSString *nssPSinPermission in nsaProtocolString){
            
            if([nssPSfromDevice isEqualToString:nssPSinPermission]){
                
                [nsmaAccessoryList addObject:eaaConnect];
                [escSessionController setupControllerForAccessory:eaaConnect withProtocolString:nssPSinPermission];
                
                [escSessionController openSession];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    //Init or share the OTA controller
                    OTAISP = [OTAController sharedController];
                    if ([TYPE_FW_APP isEqualToString:[OTAISP getFirmwareType]]) {
                        //Init the api controller
                        if(fsaAPI == nil)
                        {
                            fsaAPI = [[FileSystemAPI alloc] init:self];
                        }
                        
                        //                        uint64_t space = [fsaAPI getAvailableSpace];
                        //                        uint64_t usage = [fsaAPI totalAvailableSpace];
                        //
                        //                        dispatch_async(dispatch_get_main_queue(),^{
                        //                            CapacityText.text = [NSString stringWithFormat:@"%.02lf%%",((double)space/(double)usage)*100];
                        //                        });
                    }
                });
            }
        }
    }
}

- (void)accessoryDidDisconnect:(NSNotification *)notification
{
    EAAccessory	*eaaDisconnect = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    for(EAAccessory *eaaAccess in nsmaAccessoryList){
        if([eaaAccess connectionID] == [eaaDisconnect connectionID]){
            [nsmaAccessoryList removeObject:eaaDisconnect];
            [escSessionController closeSession];
            [escSessionController setupControllerForAccessory:nil withProtocolString:nil];
            
            fsaAPI = nil;
            OTAISP = nil;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        // CapacityText.text = @"No device";
        
        CapacityText.text = [Language get:@"Setting_msg1" alter:@"Setting_msg1"];
       // [Language get:@"Setting_msg1" alter:@"Setting_msg1"]
        // CapacityText.tag = 16;
        
    });
}

-(Boolean) CheckInternet
{
    Reachability *myNetwork = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    if(myStatus == NotReachable)
    {
        return false;
    }
    
    return true;
}


#pragma mark update data
-(void)UpdateData
{

//            Finded_Label_Name = (UILabel*) [Cell viewWithTag:11];
//            Finded_Label_Name.text = [Language get:@"Setting_Option1" alter:@"Setting_Option1"];
//            Finded_Label_Name = (UILabel*) [Cell viewWithTag:12];
//            Finded_Label_Name.text = [Language get:@"Setting_Option2" alter:@"Setting_Option2"];
//            Finded_Label_Name = (UILabel*) [Cell viewWithTag:13];
//            Finded_Label_Name.text = [Language get:@"Setting_Option3" alter:@"Setting_Option3"];
//            Finded_Label_Name = (UILabel*) [Cell viewWithTag:14];
//            Finded_Label_Name.text = [Language get:@"Setting_Option4" alter:@"Setting_Option4"];
//            Finded_Label_Name2 = (UILabel*) [Cell viewWithTag:16];
//            Finded_Label_Name2.text = [Language get:@"Setting_msg1" alter:@"Setting_msg1"];
//            Finded_Label_Name = (UILabel*) [Cell viewWithTag:15];
//            Finded_Label_Name.text = [Language get:@"Setting_Option5" alter:@"Setting_Option5"];
}

@end
