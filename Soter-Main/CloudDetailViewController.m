//
//  CloudDetailViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/21.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "CloudDetailViewController.h"
#import "Language.h"
#import "LanguageViewController.h"


#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]

@interface CloudDetailViewController ()
{
    DBRestClient *restClient;
    
    NSString *CurrentFileName;
    
    NSArray  *paths;
    NSString *documentsDirectory;
    NSString *oFilePath;
    
    Common *_Common;
    
    FileSystemAPI *fsaAPI;
    
    EADSessionController *escSessionController;
    OTAController *OTAISP;
    
    NSMutableArray *nsmaAccessoryList;
    NSArray *nsaProtocolString;
    
    int TargetMode;
    
    bool BottomMenuShowed;
    
    NSMutableArray *optionArray;
}
@end

@implementation CloudDetailViewController

@synthesize Thumbnail;
@synthesize CurrentFile;
@synthesize UploadProgress;

#define BOTTOM_BUTTON 84
#define STATUS_BAR_HEIGHT 64
#define FILENAME_HEIGHT 40
#define LOCK_ICON 88

static float sWidth;
static float sHeight;

float BottomHeight;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UI
    sWidth  = [[UIScreen mainScreen] bounds].size.width;
    sHeight = [[UIScreen mainScreen] bounds].size.height;
    
    BottomMenuShowed = false;
    self.BottomBarMenu.frame = CGRectMake(self.BottomBarMenu.frame.origin.x,
                                          self.view.frame.size.height,
                                          self.BottomBarMenu.frame.size.width,
                                          self.BottomBarMenu.frame.size.height);
    self.BottomBarMenu.backgroundColor = RGB(40.0, 114.0, 195.0, 0.8);
    
    [self.LodingIndicator startAnimating];
    
    
    //OTG
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    

    _Common = [_Common init];
    
    [self.Thumbnail setImage:[CurrentFile getThumbnail]];
    
    CurrentFileName = [NSString stringWithFormat:@"%@.%@",CurrentFile.FileName,CurrentFile.FileExtension] ;
    
    self.title = CurrentFileName;
    
    
    //Dropbox
    restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = (id)self;
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    oFilePath = [documentsDirectory stringByAppendingPathComponent:CurrentFileName];
    
    optionArray = [[NSMutableArray alloc] init];
    
    [self.Content_TextView setBackgroundColor:RGB(221,226,230,0.3)];
    self.Content_TextView.layer.cornerRadius = 10.0f;
    self.Content_TextView.layer.borderWidth = 2.0f;
    self.Content_TextView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    NSLog(@"documentsDirectory:%@",documentsDirectory);
    NSLog(@"oFilePath:%@",oFilePath);
    NSLog(@"CurrentFile.FilePath:%@",CurrentFile.FilePath);
    
    NSError *errorReading;

    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:oFilePath];
    
    if (fileExist)
    {
        if ([CurrentFile.FileExtension isEqualToString:@"txt"])
        {
            [self.Thumbnail setHidden:YES];
            [self.Content_TextView setHidden:NO];
            
            NSString *myFile = [NSString stringWithContentsOfFile:oFilePath
                                                         encoding:NSUTF8StringEncoding
                                                            error:&errorReading];
            [self.Content_TextView setText:myFile];
        }
        else
        {
            [self.Thumbnail setHidden:NO];
            [self.Content_TextView setHidden:YES];
            
            if ([CurrentFile.FileExtension isEqualToString:@"png"] ||
                [CurrentFile.FileExtension isEqualToString:@"jpg"])
            {
                unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:oFilePath
                                                                                                error:nil] fileSize];
                
                self.Thumbnail.image = [UIImage imageWithContentsOfFile:oFilePath];
                
                NSLog(@"FileSize:%lld",fileSize);
            }
            else
            {
                self.Thumbnail.image = [CurrentFile getThumbnail];
            }
        }
        
        [self.LodingIndicator stopAnimating];
        [self.UploadProgress setHidden:true];
    }
    else
    {
        NSLog(@"File \"%@\" do not exist",oFilePath);
        [restClient loadFile:CurrentFile.FilePath intoPath:oFilePath];
    }
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}
-(void) viewWillAppear:(BOOL)animated
{
    
   // [self UpdateData];
}


-(void) viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self changeViewInitOTG];
    });
}

- (void)changeViewInitOTG
{
    UIAlertView *AlertMsg;
    
    @try {
        
        if(fsaAPI == nil)
        {
            fsaAPI = [[FileSystemAPI alloc] init:self];
            
            fsaAPI.delegateForAPI = self;
        }
        
    }
    @catch (NSException *exception){
        
        
//        AlertMsg = [[UIAlertView alloc] initWithTitle:@"System Error"
//                                              message:exception.reason
//                                             delegate:nil
//                                    cancelButtonTitle:@"OK"
//                                    otherButtonTitles:nil];
    }
    @finally {
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Cloud_Move_Btn_Click:(id)sender
{
    RDActionSheet *actionSheet;
    UIAlertView *ErrorMsg;
    
    bool Enviorment = [self CheckWorkEnviorment];
    
    if(!Enviorment)
        return;
    
    if([nsmaAccessoryList count] != 0) {
      //  actionSheet = [[RDActionSheet alloc] initWithTitle:@"Select move to target"
        actionSheet = [[RDActionSheet alloc] initWithTitle:[Language get:@"Cloud_Option_Move_msg1" alter:@"Select move to target"]
                                         cancelButtonTitle:[Language get:@"Cloud_Option_Move_msg2" alter:@"Cancel"]
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"Cloud_Option_Move_msg3" alter:@"Photo Center"],[Language get:@"Cloud_Option_Move_msg4" alter:@"OTG"],nil];
       // [Language get:@"RandomKeyboard_Title" alter:@"RandomKeyboard"]
    }
    else
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:[Language get:@"Cloud_Option_Move_msg1" alter:@"Select move to target"]
                                         cancelButtonTitle:[Language get:@"Cloud_Option_Move_msg2" alter:@"Cancel"]
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"Cloud_Option_Move_msg3" alter:@"Photo Center"],nil];
    }
    
    actionSheet.callbackBlock = ^(RDActionSheetCallbackType type, NSInteger buttonIndex, NSString *buttonTitle) {
        if (type == RDActionSheetCallbackTypeClickedButtonAtIndex)
        {
            if(buttonIndex == 1)
            {
                [self CopyToPhotoCenter:oFilePath];
                [restClient deletePath:CurrentFile.FilePath];
                [self ShowMessage:[Language get:@"Cloud_Message" alter:@"System Message"]
                          Message:[NSString stringWithFormat:@"File: %@ \nMoved to 'Photo Center'",CurrentFileName]];
            }
            if(buttonIndex == 2)
            {
                [fsaAPI doWriteFileToOTG:oFilePath
                                fileName: [NSString stringWithFormat:@"/%@",CurrentFileName]];
                
                [restClient deletePath:CurrentFile.FilePath];
                [self ShowMessage:[Language get:@"Cloud_Message" alter:@"System Message"]
                          Message:[NSString stringWithFormat:@"File: %@ \nMoved to 'OTG'",CurrentFileName]];
            }
        }
    };
    
    [actionSheet showFrom:self.view];
}

- (IBAction)Cloud_Copy_Btn_Click:(id)sender
{
    RDActionSheet *actionSheet;
    
    if([nsmaAccessoryList count] != 0) {
        actionSheet = [[RDActionSheet alloc] initWithTitle:[Language get:@"Cloud_Option_Copy_msg1" alter:@"Select copy to target"]
                                         cancelButtonTitle:[Language get:@"Cloud_Option_Move_msg2" alter:@"Cancel"]
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"Cloud_Option_Move_msg3" alter:@"Photo Center"],[Language get:@"Cloud_Option_Move_msg4" alter:@"OTG"],nil];
    }
    else
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:[Language get:@"Cloud_Option_Copy_msg1" alter:@"Select copy to target"]
                                         cancelButtonTitle:[Language get:@"Cloud_Option_Move_msg2" alter:@"Cancel"]
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"Cloud_Option_Move_msg3" alter:@"Photo Center"],nil];
    }
    
    NSLog(@"Block callbacks enabled");
    actionSheet.callbackBlock = ^(RDActionSheetCallbackType type, NSInteger buttonIndex, NSString *buttonTitle) {
        
        if(type == RDActionSheetCallbackTypeClickedButtonAtIndex)
        {
            switch (buttonIndex)
            {
                case 1:
                    [self CopyToPhotoCenter:oFilePath];
                    
                    [self ShowMessage:[Language get:@"Cloud_Message" alter:@"System Message"]
                              Message:[NSString stringWithFormat:@"File: %@ \ncopied to 'Photo Center'",CurrentFileName]];
                    break;
                case 2:
                    [fsaAPI doWriteFileToOTG:oFilePath
                                    fileName:[NSString stringWithFormat:@"/%@",CurrentFileName]];
                    
                    [self ShowMessage:[Language get:@"Cloud_Message" alter:@"System Message"]
                              Message:[NSString stringWithFormat:@"File: %@ \ncopied to 'OTG'",CurrentFileName]];
                    break;
            }
            
            [self BottomMenuAnimateControl:false];
        }
    };
    [actionSheet showFrom:self.view];
}

- (void)CopyToPhotoCenter:(NSString *)fileName
{
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];
    
    UIImage* image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"System Message"
//                                                     message:[NSString stringWithFormat:@"File: %@ /ncopied to 'Photo Center'",CurrentFileName]
//                                                    delegate:self
//                                           cancelButtonTitle:@"OK"
//                                           otherButtonTitles:nil];
//    [alert show];

    
//    if (nssMode == MOVE_OTG_TO_ALBUM) {
//        [self doDeleteOTGfile:nssSrcPath];
//        //                        //[self debugMessageShow:@"MOVE_TO_ALBUM"];
//        //                        intHandle = 0;
//        //                        intHandle = [fscController deleteFileAbsolutePath:nssSrcPath];
//        //                        if(intHandle != -1){
//        //                            [fscController packDirectory];
//        //                            [self debugMessageShow:@"--- : Delete File(%@) SUCCESS!", nssSrcPath];
//        //                        } else{
//        //                            //[self debugMessageShow:@"--- : Delete File FAIL(%@)", nssFileName];
//        //                        }
//    }
}


- (void)deleteFileWithName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Have the absolute path of file named fileName by joining the document path with fileName, separated by path separator.
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    // Need to check if the to be deleted file exists.
    if ([manager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        // This function also returnsYES if the item was removed successfully or if path was nil.
        // Returns NO if an error occurred.
        [manager removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"There is an Error: %@", error);
        }
    } else {
        NSLog(@"File %@ doesn't exists", fileName);
    }
}

- (NSString*) CombinationFilePath
{
    return @"";
}

- (IBAction)DeleteFile:(id)sender
{
    [restClient deletePath:CurrentFile.FilePath];
}



- (IBAction)ActionBtnClick:(id)sender
{
    [self BottomMenuAnimateControl:BottomMenuShowed];
    
//    [self performSegueWithIdentifier:@"Cloud_Info_To_File_Browser" sender:self];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"Cloud_Info_To_File_Browser"])
    {
        FileBrowserIntegrateTableViewController *FileView = segue.destinationViewController;
        
        FileView.Target = TargetMode;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - OTG Function

- (Boolean) CheckOTG
{
    return false;
}

- (Boolean) CheckInternet
{
    return false;
}

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
                    }
                });
            }
        }
    }
}

#pragma mark Dropbox API Controller

- (void)restClient:(DBRestClient *)client
        loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType
          metadata:(DBMetadata *)metadata
{
    NSLog(@"--------------------------------------");
    NSLog(@"File loaded into path: %@", localPath);
    
    NSError *errorReading;
    
    if ([CurrentFile.FileExtension isEqualToString:@"txt"])
    {
        [self.Thumbnail setHidden:YES];
        [self.Content_TextView setHidden:NO];
        
        NSString *myFile = [NSString stringWithContentsOfFile:oFilePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:&errorReading];
        [self.Content_TextView setText:myFile];
    }
    else
    {
        [self.Thumbnail setHidden:NO];
        [self.Content_TextView setHidden:YES];
        
        if ([CurrentFile.FileExtension isEqualToString:@"png"] ||
            [CurrentFile.FileExtension isEqualToString:@"jpg"])
        {
            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:oFilePath
                                                                                            error:nil] fileSize];
            
            self.Thumbnail.image = [UIImage imageWithContentsOfFile:oFilePath];
            
            NSLog(@"FileSize:%lld",fileSize);
        }
        else
        {
            self.Thumbnail.image = [CurrentFile getThumbnail];
        }
    }
    
    [self.UploadProgress setHidden:true];
    
    [self.LodingIndicator stopAnimating];
    
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSString *debugMessage = [NSString stringWithFormat:@"%@",error];
    
    UIAlertView *errorNotify = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                                          message:debugMessage
                                                         delegate:self
                                                cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                                otherButtonTitles:nil];
    
    [errorNotify show];
    
    [self.LodingIndicator stopAnimating];
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath
{
    [self.UploadProgress setProgress:progress];
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path
{
//    UIAlertView *deleteNotify = [[UIAlertView alloc] initWithTitle:@"System Message"
//                                                           message:@"Delete Complete"
//                                                          delegate:self
//                                                 cancelButtonTitle:@"OK"
//                                                 otherButtonTitles:nil];
//    
//    [deleteNotify show];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error
{
    NSString *debugMessage = [NSString stringWithFormat:@"%@",error];
    
    UIAlertView *errorNotify = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                                          message:debugMessage
                                                         delegate:self
                                                cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                                otherButtonTitles:nil];
    
    [errorNotify show];
}

#pragma mark Program Logic

- (void)ShowMessage:(NSString*)Title Message:(NSString*)Message
{
    UIAlertView *sysMessage = [[UIAlertView alloc] initWithTitle:Title
                                                         message:Message
                                                        delegate:self
                                               cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                               otherButtonTitles:nil];
    
    [sysMessage show];
}

- (Boolean)CheckWorkEnviorment
{
    UIAlertView *ErrorMsg;
    
    if (![Common CheckInternet])
    {
        ErrorMsg = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                              message:[Language get:@"Cloud_error_msg2" alter:@"Please check your internet service\n and try again"]
                                             delegate:self
                                    cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                    otherButtonTitles:nil];
        
        [ErrorMsg show];
        
        return false;
    }
    
    if (![[DBSession sharedSession] isLinked])
    {
        ErrorMsg = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                              message:@"Authentication error:please check your dropbox service"
                                             delegate:self
                                    cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                    otherButtonTitles:nil];
        
        [ErrorMsg show];
        
        return false;
    }
    
    return true;

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
//                                fsaAPI.delegateForAPI = self;
                            }
                            
//                            uint64_t space = [fsaAPI getAvailableSpace];
//                            uint64_t usage = [fsaAPI totalAvailableSpace];
//                            
//                            dispatch_async(dispatch_get_main_queue(),^{
//                                [self.Menu_A setEnabled:true];
//                                AvailableSpace.text = [NSString stringWithFormat:@"%lld/%lld",space,usage];
//                            });
                        }
                    });
                    
                }
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

    });
}

#pragma mark update data
-(void)UpdateData
{
    self.title = [Language get:@"Cloud_Login" alter:@"Service Login"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"Cloud_Login" alter:@"Service Login"];
    
    
    
}

@end
