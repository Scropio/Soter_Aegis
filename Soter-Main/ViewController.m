
//
//  ViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/6.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//
//  Neil Change
#import "ViewController.h"
#import <iFDiskSDK_iap2/iFDiskSDK_iap2.h>
#import "FileSystemAPI.h"
#import "MainViewElement.h"
#import "pListController.h"
#import "GlobalInfo.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "Language.h"
#import "LanguageViewController.h"

@interface ViewController ()
{
    NSString *nssCMD, *nssFile;
    uint16_t uintMode;
    
    NSMutableArray *nsmaMenuItem_Standard;
    NSMutableArray *nsmaMenuItem_Test;
    
    EADSessionController *escSessionController;
    NSMutableArray *nsmaAccessoryList;
    NSArray *nsaProtocolString;
    
    FileSystemAPI *fsaAPI;
    NSString *nssPath;
    
    OTAController *OTAISP;
    BatteryDetection *batteryDe;
    streamURLSession *httpServer;
    uint8_t OTABurnin;
    
    MainViewElement *mElement;
    
    UIAlertView *Debug;
    
    GlobalInfo *GLOBAL_INFO;
    
    float sHeight;
    float sWidth;
    
    Reachability *internetReachableFoo;
}
@end

@implementation ViewController

@synthesize AvailableSpace,mElement;

@synthesize Menu_A,Menu_B,Menu_C,Menu_D,Menu_E;

bool OTA_Mode;
bool FUN_Mode;

bool DebugSwitch = false;

#define BUTTON_HEIGHT   73
#define BUTTON_WIDTH    288

NSString *SenderButton;
//hemly

//Test By Neil
#pragma mark - ViewDelegate
- (void)viewDidLoad {
    [super viewDidLoad];
    //------------------------------------------------------
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    NSLog(@"lan  = %@",preferredLang);
    
    if ([preferredLang  isEqual: @"zh-TW"]) {
        [Language setLanguage:@"zh-Hant"];
        NSLog(@"lan  = tw");
    }else{
        if ([preferredLang  isEqual: @"zh-Hans"]) {
            [Language setLanguage:@"zh-Hans"];
            NSLog(@"lan  = cn");
        }else{
            [Language setLanguage:@"en"];
            NSLog(@"lan  = en");

        }    }
    
    
    // zh-TW zh-Hans en
    //--------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popToRootViewControllerAnimated)
                                                 name:@"popToRoot"
                                               object:nil];
    
    NSLog(@"viewDidLoad");
    
    pListController *pList  = [[pListController alloc] init];
    
    GLOBAL_INFO = [GlobalInfo ShareGlobalInfo];
    GLOBAL_INFO.SuperPassword = [pList getProperty:@"SuperPassword"];
    
    NSLog(@"pList:%@",[pList getProperty:@"SuperPassword"]);
    NSLog(@"GLOBAL_INFO:%@",GLOBAL_INFO.SuperPassword);

    [self UISetting];
    
    [self.view addSubview:[mElement StatusIcon]];

//==========================================================================================
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UIAlertView *testMsg = [[UIAlertView alloc] initWithTitle:@"Debug"
                                                      message:@"Init GLOBAL.fsaAPI"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    //初始化陣列
    nsmaMenuItem_Standard = [NSMutableArray array];
    nsmaMenuItem_Test = [NSMutableArray array];
    
    //===========================================================================================
    //Create NotificationCenter to receive the external accessory state information
//    //註冊插入事件
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
//    //註冊移除事件
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    
    
    //===========================================================================================
    
    //由info.plist取得nsaProtocolString
//    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
//    
//    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
//    
//    escSessionController = [EADSessionController sharedController];
//    
//
//    if([nsmaAccessoryList count] != 0)
//    {
//        [self accessoryDidAlreadyConnect];
//    }
//    else
//    {
//        [self.Menu_A setEnabled:false];
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self UpdateData];

    
    //Create NotificationCenter to receive the external accessory state information
    //註冊插入事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDidConnect:)
                                                 name:EAAccessoryDidConnectNotification
                                               object:nil];
    //註冊移除事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDidDisconnect:)
                                                 name:EAAccessoryDidDisconnectNotification
                                               object:nil];
    
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    //===========================================================================================
    
    //由info.plist取得nsaProtocolString
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    escSessionController = [EADSessionController sharedController];
    
    
    if([nsmaAccessoryList count] != 0)
    {
        [self accessoryDidAlreadyConnect];
    }
    else
    {
        [self.Menu_A setEnabled:false];
    }
    
    Reachability *myNetwork = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
            NSLog(@"There's no internet connection at all. Display error message now.");
            break;
            
        case ReachableViaWWAN:
            NSLog(@"We have a 3G connection");
            break;
            
        case ReachableViaWiFi:
            NSLog(@"We have WiFi.");
            break;
            
        default:
            break;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    fsaAPI = nil;
    OTAISP = nil;
    
    //start
    //unregister connect
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    //unregister disconnect
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
}

- (void)viewDidUnload
{
    NSLog(@"=============================");
    NSLog(@"ViewDidUnload : Remove Notify");
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Main2Rand"])
    {
        UINavigationController *nav = segue.destinationViewController;
        
        RandomKeyboardViewController *RandView = (RandomKeyboardViewController *)nav.topViewController;
        
        RandView.Source = SenderButton;
        
        NSLog(@"Send:%@",SenderButton);
    }
}

#pragma mark -UISetting
- (void)UISetting{
    
    //Get current screen size
    sHeight = [[UIScreen mainScreen] bounds].size.height;
    sWidth  = [[UIScreen mainScreen] bounds].size.width;
    
    //Upper Bound
    float TopLine = sHeight * 0.1 + 20;
    //Lower Bound
    float BotLine = sHeight * 0.9;
    
    //Calculate X-axis Y-axis spacing
    float Y_Spacing = ((BotLine - TopLine) - (BUTTON_HEIGHT * 5)) / 6;
    float X_Spacing = (sWidth - BUTTON_WIDTH) / 2;
    
    //Button Index
    float i = 0;
    
    self.Menu_A = [[MenuButton alloc] initWithFrame:CGRectMake(X_Spacing,
                                                               TopLine + BUTTON_HEIGHT * i + Y_Spacing * ++i,
                                                               BUTTON_WIDTH,
                                                               BUTTON_HEIGHT)
                                      IconImageName:@"ic_external_storage_button"
                                          TitleText:[Language get:@"Main_Menu_Option1" alter:@"Menu_Option1"]
                   //[Language get:@"Main_Menu_Option1" alter:@"Menu_Option1"]
                                           FontSize:20];
    
    [self.Menu_A addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.Menu_A setTag:10];
    
    [self.view addSubview:self.Menu_A];
    
    self.Menu_B = [[MenuButton alloc] initWithFrame:CGRectMake(X_Spacing,
                                                               TopLine + BUTTON_HEIGHT * i + Y_Spacing * ++i,
                                                               BUTTON_WIDTH,
                                                               BUTTON_HEIGHT)
                                      IconImageName:@"ic_cloud_button"
                                          TitleText:[Language get:@"Main_Menu_Option2" alter:@"Menu_Option2"]
                                           FontSize:20];
    [self.Menu_B addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.Menu_B setTag:11];
    
    [self.view addSubview:self.Menu_B];
    
    self.Menu_C = [[MenuButton alloc] initWithFrame:CGRectMake(X_Spacing,
                                                               TopLine + BUTTON_HEIGHT * i + Y_Spacing * ++i,
                                                               BUTTON_WIDTH,
                                                               BUTTON_HEIGHT)
                                      IconImageName:@"ic_photo_center_button"
                                          TitleText:[Language get:@"Main_Menu_Option3" alter:@"Menu_Option3"]
                                           FontSize:20];
    [self.Menu_C addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.Menu_C setTag:12];
    
    [self.view addSubview:self.Menu_C];
    
    self.Menu_D = [[MenuButton alloc] initWithFrame:CGRectMake(X_Spacing,
                                                               TopLine + BUTTON_HEIGHT * i + Y_Spacing * ++i,
                                                               BUTTON_WIDTH,
                                                               BUTTON_HEIGHT)
                                      IconImageName:@"ic_account_manage_button"
                                          TitleText:[Language get:@"Main_Menu_Option4" alter:@"Menu_Option4"]
                                           FontSize:20];
    [self.Menu_D addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.Menu_D setTag:13];
    
    [self.view addSubview:self.Menu_D];
    
    self.Menu_E = [[MenuButton alloc] initWithFrame:CGRectMake(X_Spacing,
                                                               TopLine + BUTTON_HEIGHT * i + Y_Spacing * ++i,
                                                               BUTTON_WIDTH,
                                                               BUTTON_HEIGHT)
                                      IconImageName:@"ic_setting_button"
                                          TitleText:[Language get:@"Main_Menu_Option5" alter:@"Menu_Option5"]
                                           FontSize:20];
    
    [self.Menu_E addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.Menu_E setTag:14];
    
    [self.view addSubview:self.Menu_E];
}

- (void)ButtonClick:(id)sender
{
    switch ([sender tag])
    {
        case 10:
            SenderButton = @"OptionA";
            break;
        case 11:
            SenderButton = @"OptionB";
            break;
        case 12:
            SenderButton = @"OptionC";
            break;
        case 13:
            SenderButton = @"OptionD";
            break;
        case 14:
            SenderButton = @"OptionE";
            break;
    }
    
    [self performSegueWithIdentifier:@"Main2Rand" sender:sender];
}

#pragma mark iFDisk Action/Delegate
- (void)accessoryDidAlreadyConnect
{
    [escSessionController closeSession];
    [escSessionController setupControllerForAccessory:nil withProtocolString:nil];
    fsaAPI = nil;
    OTAISP = nil;
    
    for(EAAccessory *eaaAccess in nsmaAccessoryList)
    {
        NSArray	*nsaPSfromDevice = [eaaAccess protocolStrings];
        for(NSString *nssPSfromDevice in nsaPSfromDevice)
        {
            for(NSString *nssPSinPermission in nsaProtocolString)
            {
                if([nssPSfromDevice isEqualToString:nssPSinPermission])
                {
                    [escSessionController setupControllerForAccessory:eaaAccess withProtocolString:nssPSinPermission];
                    [escSessionController openSession];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                        //Init or share the OTA controller
                        OTAISP = [OTAController sharedController];
                        if ([TYPE_FW_APP isEqualToString:[OTAISP getFirmwareType]])
                        {
                            //Init the api controller
                            if( fsaAPI == nil)
                            {
                                fsaAPI = [[FileSystemAPI alloc] init:self];
                                fsaAPI.delegateForAPI = self;
                            }
                            
                            uint64_t space = [fsaAPI getAvailableSpace];
                            uint64_t usage = [fsaAPI totalAvailableSpace];
                            
                            dispatch_async(dispatch_get_main_queue(),^{
                                [self.Menu_A setEnabled:true];
                                AvailableSpace.text = [NSString stringWithFormat:@"%lld/%lld",space,usage];
                            });
                        }
                    });
                    
                }
            }
        }
    }
}

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
                            fsaAPI.delegateForAPI = self;
                        }
                        
                        uint64_t space = [fsaAPI getAvailableSpace];
                        uint64_t usage = [fsaAPI totalAvailableSpace];
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self.Menu_A setEnabled:true];
                            
                            self.
                            AvailableSpace.text = [NSString stringWithFormat:@"%lld/%lld",space,usage];
                        });
                    }
                });
            }
        }
    }
}

//The iFDisk did disconnect
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
        [self.Menu_A setEnabled:false];
    });
}

- (IBAction)getAvailable:(id)sender
{
    uint64_t space = [fsaAPI totalAvailableSpace];
    
    if(fsaAPI == nil)
    {
        AvailableSpace.text = @"fsaAPI = nil";
    }
    else
    {
        AvailableSpace.text = [NSString stringWithFormat:@"%llu",space];
    }
}

- (void)popToRootViewControllerAnimated
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark update data
-(void)UpdateData
{
    MenuButton *MenuBtn;
    UILabel *Finded_Title_Label;
    
    //MenuButton_A
    MenuBtn = [self.view viewWithTag:10];
    Finded_Title_Label = [MenuBtn viewWithTag:3];
    [Finded_Title_Label setText:[Language get:@"Main_Menu_Option1"
                                        alter:@"Main_Menu_Option1"]];
    
    //MenuButton_B
    MenuBtn = [self.view viewWithTag:11];
    Finded_Title_Label = [MenuBtn viewWithTag:3];
    [Finded_Title_Label setText:[Language get:@"Main_Menu_Option2"
                                        alter:@"Main_Menu_Option2"]];
    
    //MenuButton_C
    MenuBtn = [self.view viewWithTag:12];
    Finded_Title_Label = [MenuBtn viewWithTag:3];
    [Finded_Title_Label setText:[Language get:@"Main_Menu_Option3"
                                        alter:@"Main_Menu_Option3"]];
    
    //MenuButton_D
    MenuBtn = [self.view viewWithTag:13];
    Finded_Title_Label = [MenuBtn viewWithTag:3];
    [Finded_Title_Label setText:[Language get:@"Main_Menu_Option4"
                                        alter:@"Main_Menu_Option4"]];
    
    //MenuButton_E
    MenuBtn = [self.view viewWithTag:14];
    Finded_Title_Label = [MenuBtn viewWithTag:3];
    [Finded_Title_Label setText:[Language get:@"Main_Menu_Option5"
                                        alter:@"Main_Menu_Option5"]];

}

@end
