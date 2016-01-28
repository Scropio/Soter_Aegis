//
//  ExternalFileInfoViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/7/3.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "ExternalFileInfoViewController.h"
#import "GlobalInfo.h"
#import "RDActionSheet.h"
#import "File.h"
#import "Language.h"
#import "LanguageViewController.h"

#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]

@interface ExternalFileInfoViewController () <DBRestClientDelegate>
{
    //Ray for Ver.0.3.0
    DBRestClient *restClient;
    
    //Ray 20151005
    bool bEncFile;
    FileSystemAPI *fsaAPI;
    EADSessionController *escSessionController;
    OTAController *OTAISP;
    NSMutableArray *nsmaAccessoryList;
    NSArray *nsaProtocolString;
    
    //Default System Cell
    float sWidth;
    float sHeight;
    
    //Custom UI Setting
    float X_PADDING;
    
    float BOTTOM_BAR_HEIGHT;
    float BOTTOM_BUTTON_SIZE;
    float BOTTOM_BUTTON_PADDING_X;
    float BOTTOM_BUTTON_PADDING_Y;
    
    float STATUS_BAR_HEIGHT;
    float FILENAME_HEIGHT;
    float LOCK_ICON;
    
    GlobalInfo *GLOBAL_INFO;
    
    int TargetMode;
    
    bool BottomMenuShowed;
    
    UIAlertController *AlertMessage;
}

@end

//#define BOTTOM_BUTTON_SIZE 84
//#define STATUS_BAR_HEIGHT 64
//#define FILENAME_HEIGHT 40
//#define LOCK_ICON 88

@implementation ExternalFileInfoViewController

//@synthesize CurrentFile,OTGFile;
@synthesize CurrentFile,OTGFile,ActionButton;
@synthesize EncryptBtn;

bool OTGDebugSwitch = true;

#pragma mark - ViewDelegate
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Dropbox
    restClient = [[DBRestClient alloc] initWithSession: [DBSession sharedSession]];
    restClient.delegate = self;
    
    //    [self.LoadingIndicator startAnimating];
    
    //Set UI default value
    GLOBAL_INFO = [GlobalInfo ShareGlobalInfo];
    
    sWidth  = GLOBAL_INFO.SCREEN_WIDTH;
    sHeight = GLOBAL_INFO.SCREEN_HEIGHT;
    
    BOTTOM_BAR_HEIGHT       = 104;
    BOTTOM_BUTTON_SIZE      = 84;
    BOTTOM_BUTTON_PADDING_X = (sWidth - (4 * BOTTOM_BUTTON_SIZE))/5;
    BOTTOM_BUTTON_PADDING_Y = (BOTTOM_BAR_HEIGHT - BOTTOM_BUTTON_SIZE)/2;
    
    STATUS_BAR_HEIGHT       = 64; //20 + 44
    FILENAME_HEIGHT         = 40;
    LOCK_ICON               = 88;
    
    BottomMenuShowed = false;
    self.BottomBarMenu.frame = CGRectMake(self.BottomBarMenu.frame.origin.x,
                                          self.view.frame.size.height,
                                          self.BottomBarMenu.frame.size.width,
                                          self.BottomBarMenu.frame.size.height);
    
    self.BottomBarMenu.backgroundColor = RGB(40.0, 114.0, 195.0, 0.8);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDidDisconnect:)
                                                 name:EAAccessoryDidDisconnectNotification
                                               object:nil];
    
    //Ray for Ver.0.3.0
    //For bug
    bEncFile = false;
    
    if ([CurrentFile.FileExtension  isEqual: @"png"] ||
        [CurrentFile.FileExtension  isEqual: @"jpg"])
    {
        self.FileTextView.hidden = true;
        self.FileIcon.hidden = false;
        
        [self.FileIcon setImage: [UIImage imageWithData:self.OTGFile]];
    }
    else if( [CurrentFile.FileExtension isEqualToString: @"txt"])
    {
        self.FileTextView.hidden = false;
        self.FileIcon.hidden = true;
        
        self.FileTextView.text = [[NSString alloc] initWithData:OTGFile encoding:NSUTF8StringEncoding];
    }
    else if( [CurrentFile.FileExtension isEqualToString: @"enc"])
    {
        bEncFile = true;
        [self.EncryptBtn setBackgroundImage:[UIImage imageNamed:@"Menu06_decryption_icon"] forState:UIControlStateNormal];
        self.FileTextView.hidden = true;
        self.FileIcon.hidden = false;
        [self.FileIcon setImage:[CurrentFile getThumbnail]];
    }
    else
    {
        self.FileTextView.hidden = true;
        self.FileIcon.hidden = false;
        
        [self.FileIcon setImage:[CurrentFile getThumbnail]];
    }
    
    self.title = CurrentFile.FileName;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    //[DropBox Initialize]
    restClient = [[DBRestClient alloc] initWithSession: [DBSession sharedSession]];
    restClient.delegate = self;
    
    //[self changeViewInitOTG];
    
//    UIButton *btnA = [UIButton alloc] initWithFrame:<#(CGRect)#>
    
    UIBarButtonItem *btnA = [[UIBarButtonItem alloc] initWithTitle:@"A"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:nil];
    
    UIBarButtonItem *btnB = [[UIBarButtonItem alloc] initWithTitle:@"B"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:nil];
    
    
    UIBarButtonItem *btnC = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                          target:self
                                                                          action:nil];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btnA,btnB,btnC,nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self UpdateData];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self changeViewInitOTG];
    });
}

//Ray for Ver.0.3.0
//For bug
//start
-(void) viewDidDisappear:(BOOL)animated
{
    fsaAPI = nil;
    OTAISP = nil;
}
//end

- (void)accessoryDidDisconnect:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UI Delegate

//Initial OTG first after change view
//Ray 20150807
- (void)changeViewInitOTG {
    if(fsaAPI == nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            fsaAPI = [[FileSystemAPI alloc] init:self];
        });
    }
}


- (IBAction)OTG_Move_Btn_Click:(id)sender
{
    RDActionSheet *actionSheet = [[RDActionSheet alloc]
                                  initWithTitle:[Language get:@"OTG_Option_Move_msg1" alter:@"Select move to target"]
                                  cancelButtonTitle:[Language get:@"OTG_Option_Move_msg2" alter:@"Cancel"]
                                  primaryButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:[Language get:@"OTG_Option_Move_msg4" alter:@"Cloud"],[Language get:@"OTG_Option_Move_msg3" alter:@"Photo Center"],nil];
    //otherButtonTitles:@"OTG",@"Cloud",@"Photo Center",nil];
    
    self.title = @"Move";
    
    NSLog(@"Block callbacks enabled");
    actionSheet.callbackBlock = ^(RDActionSheetCallbackType type, NSInteger buttonIndex, NSString *buttonTitle) {
        
        //Ray 20151001
        if(type == RDActionSheetCallbackTypeClickedButtonAtIndex)
        {
            if([buttonTitle isEqualToString:@"Cloud"])
            {
                if ([self UploadToCloud])
                {
                    [fsaAPI doDeleteOTGfile:CurrentFile.FilePath];
                }
            }
            else if([buttonTitle isEqualToString:@"Photo Center"])
            {
                self.title = CurrentFile.FilePath;
                
                [self MoveToPhotoCenter:CurrentFile.FilePath];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    [actionSheet showFrom:self.view];
}

- (IBAction)OTG_Copy_Btn_Click:(id)sender
{
    RDActionSheet *actionSheet;
    
    self.title = @"Copy";
    
    if([Common CheckInternet])
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:[Language get:@"OTG_Option_Move_msg1" alter:@"Select move to target"]
                                         cancelButtonTitle:[Language get:@"OTG_Option_Move_msg2" alter:@"Cancel"]
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"OTG_Option_Move_msg3" alter:@"Photo Center"],@"Cloud",nil];
    }
    else
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:[Language get:@"OTG_Option_Move_msg1" alter:@"Select move to target"]
                                         cancelButtonTitle:[Language get:@"OTG_Option_Move_msg2" alter:@"Cancel"]
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"OTG_Option_Move_msg3" alter:@"Photo Center"],nil];
    }

    
    NSLog(@"Block callbacks enabled");
    actionSheet.callbackBlock = ^(RDActionSheetCallbackType type, NSInteger buttonIndex, NSString *buttonTitle) {
        
        //Ray 20151001
        if(type == RDActionSheetCallbackTypeClickedButtonAtIndex)
        {
            if([buttonTitle isEqualToString:@"Cloud"])
            {
                [self UploadToCloud];
            }
            else if([buttonTitle isEqualToString:@"Photo Center"])
            {
                [self CopyToPhotoCenter:CurrentFile.FilePath];
            }

            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    [actionSheet showFrom:self.view];
}

- (IBAction)OTG_Delete_Btn_Click:(id)sender
{
    [fsaAPI doDeleteOTGfile:CurrentFile.FilePath];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//Ray for Ver.0.3.0
//For cloud
//start
#pragma mark - Cloud
-(BOOL) UploadToCloud
{
    self.title = @"UploadToCloud";
    
    if (![[DBSession sharedSession] isLinked])
    {
        UIAlertView *Notify = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                                         message:[Language get:@"OTG_error_msg" alter:@"Please login your Dropbox"]
                                                        delegate:self
                                               cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                               otherButtonTitles: nil];
        
        [Notify show];
    }
    else
    {
        NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString    *path = [paths firstObject];
        
        path = [path stringByAppendingString:@"/"];
        path = [path stringByAppendingString:CurrentFile.FileName];
        
        
        
//        UIAlertView *debugMsg = [[UIAlertView alloc] initWithTitle:@"System Message"
//                                                           message:path
//                                                          delegate:self
//                                                 cancelButtonTitle:@"OK"
//                                                 otherButtonTitles:nil];
//        
//        [debugMsg show];


//        NSData *imgData = [fsaAPI doReadOTGfile:CurrentFile.FilePath];
//
        NSString *file = [NSTemporaryDirectory() stringByAppendingString:CurrentFile.FileName];
//
        [OTGFile writeToFile:file atomically:YES];
//
        self.title = @"WriteToFile Success";
        
        [restClient uploadFile:CurrentFile.FilePath
                        toPath:@"/"
                 withParentRev:nil
                      fromPath:file];
        
        AlertMessage = [UIAlertController alertControllerWithTitle:[Language get:@"OTG_Message" alter:@"System Message"]
                                                           message:[Language get:@"OTG_msg" alter:@"Uploading to cloud service"]
                                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:AlertMessage animated:YES completion:nil];
        
        return true;
    }
    
    return false;
}

- (void)restClient:(DBRestClient *)client
      uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath
          metadata:(DBMetadata *)metadata
{
    
    [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSString *debugMessage = [NSString stringWithFormat:@"%@",error];
    
    UIAlertView *errorNotify = [[UIAlertView alloc] initWithTitle:[Language get:@"OTG_Message" alter:@"System Message"]
                                                          message:debugMessage
                                                         delegate:self
                                                cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                                otherButtonTitles:nil];
    
//    [self.UploadProgress setHidden:true];
    
    [errorNotify show];
}

- (void)restClient:(DBRestClient*)client
    uploadProgress:(CGFloat)progress
           forFile:(NSString *)destPath
              from:(NSString *)srcPath
{
//    [self.UploadProgress setProgress:progress];
}



//TODO:Upload file to OTG by file path
-(bool) UploadToOTG:(File *)File
{
    return true;
}

//Ray 20151005
//Move "jpg" "png" from OTG to photo center
-(bool) MoveToPhotoCenter:(NSString *)nssSrctPath
{
    bool result = false;
    NSArray *array = [nssSrctPath componentsSeparatedByString:@"."];
    NSString *nssFileExtension = array[array.count - 1];
    
    if (([nssFileExtension isEqual: @"PNG"]) || ([nssFileExtension isEqual: @"png"]) || ([nssFileExtension isEqual: @"JPG"]) || ([nssFileExtension isEqual: @"jpg"])) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [fsaAPI doFileOTGtoAlbum:MOVE_OTG_TO_ALBUM SrcPath:nssSrctPath];
        });
        result = true;
    } else {
        NSString *str = @"Only supply (.jpg) (.png)!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"OTG_Message" alter:@"System Message"] message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
    return result;
}

- (IBAction)Encrypt_Btn_Click:(id)sender {

    NSString *title = [Language get:@"OTG_Message" alter:@"System Message"];
    NSString *msg = [Language get:@"OTG_error_msg2" alter:@"Please input key!\nMore than 5 numbers!"];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:[Language get:@"OTG_Option_Move_msg2" alter:@"Cancel"]
                                           otherButtonTitles:[Language get:@"Cloud_OK" alter:@"OK"], nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

//Ray for Ver.0.3.0
//For encrypt/decrypt input key
//start
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //self.title = [[alertView textFieldAtIndex:0] text];
    NSString *str = [[alertView textFieldAtIndex:0] text];
    switch (buttonIndex) {
        case 0://Cancel
            break;
        case 1: //Enter
            if (str.length >= 5) {
                UIAlertController *alertController;
                NSString *nssDestPath = [CurrentFile.FilePath substringWithRange:NSMakeRange (1, CurrentFile.FilePath.length - 1)];
                //For process bar
                if (bEncFile) {
                    str = [Language get:@"OTG_msg2" alter:@"The file is decrypting!\nPlease wait..."];
                    alertController = [UIAlertController
                                       alertControllerWithTitle:[Language get:@"OTG_Message" alter:@"System Message"]
                                       message:str
                                       preferredStyle:UIAlertControllerStyleAlert];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                        [self presentViewController:alertController animated:YES completion:nil];
                        [fsaAPI doAESDecryptOTGfile:nssDestPath passWord:[[alertView textFieldAtIndex:0] text]];
                        //[fsaAPI doDeleteOTGfile:CurrentFile.FilePath];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                        });
                    });
                } else {
                    str = [Language get:@"OTG_msg3" alter:@"The file is encrypting!\nPlease wait..."];
                    alertController = [UIAlertController
                                       alertControllerWithTitle:[Language get:@"OTG_Message" alter:@"System Message"]
                                       message:str
                                       preferredStyle:UIAlertControllerStyleAlert];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                        [self presentViewController:alertController animated:YES completion:nil];
                        [fsaAPI doAESEncryptOTGfile:nssDestPath passWord:[[alertView textFieldAtIndex:0] text]];
                        //[fsaAPI doDeleteOTGfile:CurrentFile.FilePath];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                        });
                    });
                }
            } else {
                NSString *title = [Language get:@"OTG_Message" alter:@"System Message"];
                NSString *msg = [Language get:@"OTG_error_msg2" alter:@"Please input key!\nMore than 5 numbers!"];
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                                 message:msg
                                                                delegate:self
                                                       cancelButtonTitle:[Language get:@"OTG_Option_Move_msg2" alter:@"Cancel"]
                                                       otherButtonTitles:[Language get:@"Cloud_OK" alter:@"OK"], nil];
                
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert show];
            }
            break;
        default:
            break;
    }
}
//end


//Ray 20151004
//Copy "jpg" "png" from OTG to photo center
-(bool) CopyToPhotoCenter:(NSString *)nssSrctPath
{
    bool result = false;
    NSArray *array = [nssSrctPath componentsSeparatedByString:@"."];
    NSString *nssFileExtension = array[array.count - 1];
    
    if (([nssFileExtension isEqual: @"PNG"]) || ([nssFileExtension isEqual: @"png"]) || ([nssFileExtension isEqual: @"JPG"]) || ([nssFileExtension isEqual: @"jpg"])) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [fsaAPI doFileOTGtoAlbum:COPY_OTG_TO_ALBUM SrcPath:nssSrctPath];
        });
        result = true;
    } else {
        NSString *str = @"Only supply (.jpg) (.png)!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"OTG_Message" alter:@"System Message"] message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
    return result;
}

-(void) DebugMsg: (NSString*) Message
{
    UIAlertView *Debug = [[UIAlertView alloc] initWithTitle:@"Debug"
                                                    message:Message
                                                   delegate:self
                                          cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                          otherButtonTitles:nil];
    
    if(OTGDebugSwitch)
    {
        [Debug show];
    }
}

- (IBAction)ActionBtnClick:(id)sender {
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"OTG_Info_To_File_Browser"])
    {
        FileBrowserIntegrateTableViewController *FileView = segue.destinationViewController;
        
        FileView.Target = TargetMode;
    }
    
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
}

#pragma mark -
#pragma mark Loading Func

- (void)setLoading:(Boolean)Loading
{
    [self.LoadingMask setHidden:!Loading];
    
    Loading ? ([self.LoadingIndicator startAnimating]) : ([self.LoadingIndicator stopAnimating]);
}

#pragma mark UIAlertController

#pragma mark update data
-(void)UpdateData
{
    self.title = [Language get:@"OTG_Title" alter:@"OTG"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"OTG_Title" alter:@"OTG"];
    
    
    
}
 

@end
