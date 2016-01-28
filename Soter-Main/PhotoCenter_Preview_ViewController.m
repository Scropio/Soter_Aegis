//
//  PhotoCenter_Preview_ViewController.m
//  Soter
//
//  Created by Neil on 2015/4/23.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "PhotoCenter_Preview_ViewController.h"
#import "GlobalInfo.h"
#import "RDActionSheet.h"
#import "FileSystemAPI.h"
#import <iFDiskSDK_iap2/iFDiskSDK_iap2.h>
#import "Language.h"
#import "LanguageViewController.h"

#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]

@interface PhotoCenter_Preview_ViewController () <DBRestClientDelegate>
{
    DBRestClient *restClient;
    
    GlobalInfo *GLOBAL_INFO;
    
    float SCREEN_HEIGHT;
    float SCREEN_WIDTH;
    
    float SPACING;
    
    FileSystemAPI *fsaAPI;
    EADSessionController *escSessionController;
    OTAController *OTAISP;
    
    NSMutableArray *nsmaAccessoryList;
    NSArray *nsaProtocolString;
    
    int TargetMode;
    
    bool BottomMenuShowed;
    
    bool OTG_Plugin;
    bool Internet;
    bool Cloud;
    
}
@end

@implementation PhotoCenter_Preview_ViewController

@synthesize PreviewPhoto,FullPhoto,PhotoName,PhotoAsset,UploadIndicator;
@synthesize UploadProgress;
@synthesize Encrypt_Btn,Move_Btn,Copy_Btn,Del_Btn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    GLOBAL_INFO = [GlobalInfo ShareGlobalInfo];
    
    self.BottomBarMenu.backgroundColor = RGB(40.0, 114.0, 195.0, 0.8);
    
    
    SPACING = 0.0f;
    
    SCREEN_HEIGHT = GLOBAL_INFO.SCREEN_HEIGHT;
    SCREEN_WIDTH  = GLOBAL_INFO.SCREEN_WIDTH;

//    self.FullPhoto.frame = CGRectMake(SPACING,
//                                      SPACING,
//                                      (SCREEN_WIDTH-SPACING*2),
//                                      SCREEN_HEIGHT - SPACING - 84);
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(accessoryDidConnect:)
//                                                 name:EAAccessoryDidConnectNotification object:nil];
    
    [FullPhoto setImage:self.PreviewPhoto];
    
    NSLog(@"PhotoName:%@",self.PhotoName);

    
    self.FullPhoto.contentMode = UIViewContentModeScaleAspectFit;
    // Do any additional setup after loading the view.
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    restClient = [[DBRestClient alloc] initWithSession: [DBSession sharedSession]];
    restClient.delegate = self;
    
    [UploadIndicator stopAnimating];
    
    [self changeViewInitOTG];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //Ray for Ver.1.0.1
    //start
    //===========================================================================================
    //Create NotificationCenter to receive the external accessory state information
    //    //註冊插入事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnectPhoto:) name:EAAccessoryDidConnectNotification object:nil];
    //    //註冊移除事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnectPhoto:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    //===========================================================================================
    
    //由info.plist取得nsaProtocolString
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    escSessionController = [EADSessionController sharedController];
    
    
    if([nsmaAccessoryList count] != 0)
    {
        [self accessoryDidAlreadyConnectPhoto];
    }
    //end
    
    BottomMenuShowed = false;
    self.BottomBarMenu.frame = CGRectMake(self.BottomBarMenu.frame.origin.x,
                                          self.view.bounds.size.height,
                                          self.BottomBarMenu.frame.size.width,
                                          self.BottomBarMenu.frame.size.height);
}

#pragma mark - OTG Function

//Initial OTG first after change view
//Ray 20150807
- (void)changeViewInitOTG {
    if(fsaAPI == nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            fsaAPI = [[FileSystemAPI alloc] init:self];
            fsaAPI.delegateForAPI = self;
        });
    }
}

- (void)accessoryDidAlreadyConnectPhoto
{
    //[nsmaAccessoryList removeObject:self];
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
                        }
                    });
                    
                }
            }
        }
    }
}

//The iFDisk did connect
- (void)accessoryDidConnectPhoto:(NSNotification *)notification
{
    //    NSString *str6 = @"accessoryDidConnect";//[NSString stringWithFormat:@"nssPassWord(%@)", nssPassWord];
    //    UIAlertView *alert6 = [[UIAlertView alloc] initWithTitle:@"Message" message:str6 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [alert6 show];
    //    });
    
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
                    }
                });
            }
        }
    }
}

//The iFDisk did disconnect
- (void)accessoryDidDisconnectPhoto:(NSNotification *)notification
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
}
//end

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.bounds.size;
}


#pragma mark - UI Delegate
-(BOOL) CopyToCloud
{
    if (![[DBSession sharedSession] isLinked])
    {
//        [[DBSession sharedSession] linkFromController:self];
//        NSLog(@"Dropbox Re-linked");
        UIAlertView *Notify = [[UIAlertView alloc] initWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                         message:[Language get:@"PhotoCenter_error_msg2" alter:@"Please login your Dropbox"]
                                                        delegate:self
                                               cancelButtonTitle:[Language get:@"PhotoCenter_OK" alter:@"OK"]
                                               otherButtonTitles: nil];
        
        [Notify show];
        
    }
    else
    {
        NSLog(@"Upload to Cloud");
        
        [UploadIndicator startAnimating];
        
        ALAssetRepresentation *rep = [PhotoAsset defaultRepresentation];
        
        NSString *Path = rep.url.absoluteString;
        Path = [Path componentsSeparatedByString:@"&"][0];
        
        NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString    *path = [paths firstObject];
        
        path = [path stringByAppendingString:@"/"];
        
        path = [path stringByAppendingString:self.PhotoName];
        
        NSString *photoExtension = [[self.PhotoName pathExtension] lowercaseString];
        
        NSData *imgData;
        
        if ([photoExtension isEqualToString:@"jpg"])
        {
            imgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(self.PreviewPhoto,1)];
        }
        else
        {
            imgData = [[NSData alloc] initWithData:UIImagePNGRepresentation(self.PreviewPhoto)];
        }
        
        NSString *file = [NSTemporaryDirectory() stringByAppendingString:self.PhotoName];
        
        [imgData writeToFile:file atomically:YES];
        
        [restClient uploadFile:self.PhotoName
                        toPath:@"/"
                 withParentRev:nil
                      fromPath:file];
        
        [self.UploadProgress setHidden:false];
        
        return true;
    }
    
    return false;
}

- (void) MoveToCloud
{
    if([self CopyToCloud])
    {
        [self Photo_Delete];
    }
}

- (void)restClient:(DBRestClient *)client
      uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath
          metadata:(DBMetadata *)metadata
{
    [self.UploadProgress setHidden:true];
    
//    UIAlertView *deleteNotify = [[UIAlertView alloc] initWithTitle:@"System Message"
//                                                           message:@"Upload Complete"
//                                                          delegate:self
//                                                 cancelButtonTitle:@"OK"
//                                                 otherButtonTitles:nil];
    
    UIAlertView *deleteNotify = [[UIAlertView alloc] initWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                           message:metadata.path
                                                          delegate:self
                                                 cancelButtonTitle:[Language get:@"PhotoCenter_OK" alter:@"OK"]
                                                 otherButtonTitles:nil];
    
    [deleteNotify show];
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    
    [UploadIndicator stopAnimating];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    NSString *debugMessage = [NSString stringWithFormat:@"%@",error];
    
    UIAlertView *errorNotify = [[UIAlertView alloc] initWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                          message:debugMessage
                                                         delegate:self
                                                cancelButtonTitle:[Language get:@"PhotoCenter_OK" alter:@"OK"]
                                                otherButtonTitles:nil];
    
    [self.UploadProgress setHidden:true];
    
    [errorNotify show];
}

- (void)restClient:(DBRestClient*)client
    uploadProgress:(CGFloat)progress
           forFile:(NSString *)destPath
              from:(NSString *)srcPath
{
    [self.UploadProgress setProgress:progress];
}

//TODO: Upload photo to external storage
-(BOOL) UploadToOTG
{
    [self CopyToOTG];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                   message:[Language get:@"PhotoCenter_Option_Move_msg4" alter:@"Move to photo center"]
                                                  delegate:self
                                         cancelButtonTitle:[Language get:@"PhotoCenter_OK" alter:@"OK"]
                                         otherButtonTitles:nil];
    
    [alert show];
    
    return false;
}

-(bool) MoveToOTG
{
    self.title = @"MoveToOTG";
    
    if ([self CopyToOTG])
    {
        [self Photo_Delete];
        self.title = @"Photo Delete";
    }
    
    return true;
}

-(bool) CopyToOTG
{
    NSString *DestFile = [NSString stringWithFormat:@"/%@",self.PhotoName];
    
    UIImage *DestPhoto = [UIImage imageWithCGImage:self.FullPhoto.image.CGImage];
    
    __block NSString *Extension = [[DestFile pathExtension] uppercaseString];
    
    if(![Extension isEqualToString:@"JPG"] && ![Extension isEqualToString:@"PNG"])
    {
        UIAlertView *WarningMsg = [[UIAlertView alloc] initWithTitle:[Language get:@"PhotoCenter_error_msg" alter:@"Warning"]
                                                             message:[Language get:@"PhotoCenter_error_msg1" alter:@"Format is not support"]
                                                            delegate:self
                                                   cancelButtonTitle:[Language get:@"PhotoCenter_OK" alter:@"OK"]
                                                   otherButtonTitles:nil];
        [WarningMsg show];
        
        return false;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        if([Extension isEqualToString:@"JPG"])
        {
            [fsaAPI doWriteImageToOTG:JPG
                                Image:DestPhoto
                             fileName:DestFile];
        }
        else if([Extension isEqualToString:@"PNG"])
        {
            [fsaAPI doWriteImageToOTG:PNG
                                Image:DestPhoto
                             fileName:DestFile];
        }
    });
    
    return true;
}


- (IBAction)Encrypt_Btn_Click:(id)sender {
    NSLog(@"Encrypt Btn Click");
}


- (IBAction)Photo_Move_Btn_Click:(id)sender
{
    RDActionSheet *actionSheet = [self RDActionOptionProcessor:[Language get:@"PhotoCenter_Option_Move_msg1" alter:@"Select move to target"]
                                                  CancelButton:[Language get:@"PhotoCenter_Cancel" alter:@"Cancel"]];
    
    actionSheet.callbackBlock = ^(RDActionSheetCallbackType type, NSInteger buttonIndex, NSString *buttonTitle) {
        if(type == RDActionSheetCallbackTypeClickedButtonAtIndex)
        {
            if([buttonTitle isEqualToString:@"OTG"])
            {
                [self MoveToOTG];
            }
            
            if([buttonTitle isEqualToString:@"Cloud"])
            {
                [self MoveToCloud];
            }
        }
    };
    
    [actionSheet showFrom:self.view];
}

- (IBAction)Photo_Copy_Btn_Click:(id)sender
{
    RDActionSheet *actionSheet = [self RDActionOptionProcessor:[Language get:@"PhotoCenter_Option_Copy_msg1" alter:@"Select copy to target"]
                                                  CancelButton:[Language get:@"PhotoCenter_Cancel" alter:@"Cancel"]];
    
    NSLog(@"Block callbacks enabled");
    actionSheet.callbackBlock = ^(RDActionSheetCallbackType type, NSInteger buttonIndex, NSString *buttonTitle) {
        if(type == RDActionSheetCallbackTypeClickedButtonAtIndex)
        {
            if([buttonTitle isEqualToString:@"OTG"])
            {
                [self CopyToOTG];
            }
            
            if([buttonTitle isEqualToString:@"Cloud"])
            {
                [self CopyToCloud];
            }
        }
    };

    [actionSheet showFrom:self.view];
}
- (IBAction)Photo_Delete_Btn_Click:(id)sender
{
    [self Photo_Delete];
}

- (void) Photo_Delete
{
    ALAssetRepresentation *rep = self.PhotoAsset.defaultRepresentation;
    
    NSURL *u = rep.url;
    //    NSString *u_String = u.absoluteString;
    
    NSMutableArray *PhotoArray = [[NSMutableArray alloc]init];
    
    [PhotoArray addObject:u];
    
    PHFetchResult *asset = [PHAsset fetchAssetsWithALAssetURLs:PhotoArray options:nil];
    
    [asset enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"enumerateObjectsUsingBlock");
        
        [[PHPhotoLibrary sharedPhotoLibrary]
         performChanges:^{
            BOOL req = [obj canPerformEditOperation:PHAssetEditOperationDelete];
            if (req) {
                NSLog(@"canPerformEditOperation");
                [PHAssetChangeRequest deleteAssets:@[obj]];
            }
         }
         completionHandler:^(BOOL success, NSError *error){
             if (success){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.navigationController popViewControllerAnimated:YES];
                 });
             }
             else
             {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                 UIAlertView *Error = [[UIAlertView alloc] initWithTitle:@"System Error"
//                                                                 message:error.description
//                                                                delegate:self
//                                                       cancelButtonTitle:@"OK"
//                                                       otherButtonTitles:nil];
//                 
//                 [Error show];
//                 });
             }
         }];
    }];
}

//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    
//    int currentPage = collectionMedia.contentOffset.x / collectionMedia.bounds.size.width;
//    float width = collectionMedia.bounds.size.height;
//    
//    [UIView animateWithDuration:duration animations:^{
//        [self.collectionMedia setContentOffset:CGPointMake(width * currentPage, 0.0) animated:NO];
//        [[self.collectionMedia collectionViewLayout] invalidateLayout];
//    }];
//}

- (IBAction)ActionBtnClick:(id)sender {
    
    [self UpdateDeviceStatus];
    
    if(OTG_Plugin )
    {
        self.Encrypt_Btn.enabled = true;
        
//        if(Internet && Cloud)
//        {
//            self.Move_Btn.enabled = false;
//            self.Copy_Btn.enabled = false;
//        }
//        else
//        {
//            self.Move_Btn.enabled = true;
//            self.Copy_Btn.enabled = true;
//        }
    }
    else
    {
        self.Encrypt_Btn.enabled = false;
        
        if(Internet && Cloud)
        {
            self.Move_Btn.enabled = true;
            self.Copy_Btn.enabled = true;
        }
        else
        {
            self.Move_Btn.enabled = false;
            self.Copy_Btn.enabled = false;
        }
    }
    
//    self.Move_Btn.enabled = true;
//    self.Copy_Btn.enabled = true;
    
    [self BottomMenuAnimateControl:BottomMenuShowed];
}

-(void) BottomMenuAnimateControl:(Boolean)showed
{
    if(BottomMenuShowed)
    {
        [UIView animateWithDuration:0.6 animations:^{
            self.BottomBarMenu.frame = CGRectMake(self.BottomBarMenu.frame.origin.x,
                                                  self.view.frame.size.height,
                                                  self.BottomBarMenu.frame.size.width,
                                                  self.BottomBarMenu.frame.size.height);
        }];
        
        BottomMenuShowed = false;
    }
    else
    {
        [UIView animateWithDuration:0.6 animations:^{
            self.BottomBarMenu.frame = CGRectMake(self.BottomBarMenu.frame.origin.x,
                                                  self.view.frame.size.height - self.BottomBarMenu.frame.size.height,
                                                  self.BottomBarMenu.frame.size.width,
                                                  self.BottomBarMenu.frame.size.height);
        }];
        
        BottomMenuShowed = true;
    }
}

#pragma mark - program login function
-(void) UpdateDeviceStatus
{
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    OTG_Plugin  = ([nsmaAccessoryList count] != 0      ? (true) : (false));
    Internet    = ([Common CheckInternet]              ? (true) : (false));
    Cloud       = ([[DBSession sharedSession] isLinked]? (true) : (false));
    
    self.title = [NSString stringWithFormat:@"%d", OTG_Plugin];
    
    
//    UIAlertView *errorNotify = [[UIAlertView alloc] initWithTitle:@"System Message"
//                                                          message:[NSString stringWithFormat:@"nsmaAccessory.count = %lu",(unsigned long)nsmaAccessoryList.count]
//                                                         delegate:self
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//    
//    [errorNotify show];

}

-(RDActionSheet*) RDActionOptionProcessor:(NSString *)Title
                            CancelButton:(NSString *)BtnText
{
    [self UpdateDeviceStatus];
    
    RDActionSheet *actionSheet;
    
    if(OTG_Plugin && (Internet && Cloud))
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:Title
                                         cancelButtonTitle:BtnText
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"PhotoCenter_OTG" alter:@"OTG"],[Language get:@"PhotoCenter_Cloud" alter:@"Cloud"],nil];
    }
    
    if(OTG_Plugin && !(Internet && Cloud))
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:Title
                                         cancelButtonTitle:BtnText
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"PhotoCenter_OTG" alter:@"OTG"],nil];
    }
    
    if(!OTG_Plugin && (Internet && Cloud))
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:Title
                                         cancelButtonTitle:BtnText
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"PhotoCenter_Cloud" alter:@"Cloud"],nil];
    }
    
    return actionSheet;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
