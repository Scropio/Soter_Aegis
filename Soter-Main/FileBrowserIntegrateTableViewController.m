//
//  FileBrowserIntegrateTableViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/9/8.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "FileBrowserIntegrateTableViewController.h"
#import "Language.h"
#import "LanguageViewController.h"

@interface FileBrowserIntegrateTableViewController () <DBRestClientDelegate>
{
    NSArray *ExistFilePathArray;
    
    //OTG
    FileSystemAPI *fsaAPI;
    OTAController *OTAISP;
    
    NSMutableArray *nsmaAccessoryList;
    
    int ActionCode;
    
    //Cloud
    NSMutableArray *PathList;
    NSMutableArray *FolderList;
    NSMutableArray *FileList;
    NSMutableArray *FullList;
    
    UIAlertController *LoadingAlert;
    
    DBRestClient *restClient;
    
    UIAlertController *ProcessStatusAlertView;
    
    UIAlertController *ProcessFinishAlertView;
        UIAlertAction *ConfirmBtn;
    
    UIAlertView *debug;
    
    int ProcessIndex;
}
@end

@implementation FileBrowserIntegrateTableViewController

@synthesize Source,Target,Action;
@synthesize TargetFiles;
@synthesize TagetBrowserTableView;

static NSString *FileCellIdentifier = @"FileCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.Target == ExternalStorage ? (self.title = @"OTG"):(self.title = @"CLOUD");

    if(self.Target == ExternalStorage)
    {
        self.title = @"OTG";
        
        for(int i = 0 ; i < TargetFiles.count ; i++)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                            message:TargetFiles[i]
                                                           delegate:self
                                                  cancelButtonTitle:[Language get:@"PhotoCenter_OK" alter:@"OK"]
                                                  otherButtonTitles:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
        }
    }
    else
    {
        self.title = @"Cloud";
    }
    
    [self.TagetBrowserTableView registerNib:[UINib nibWithNibName:@"FileCellView"
                                                           bundle:nil]
                     forCellReuseIdentifier:FileCellIdentifier];
    
    


    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDidDisconnect:)
                                                 name:EAAccessoryDidDisconnectNotification
                                               object:nil];
    
    //Set Background
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    if(self.Target == ExternalStorage && self.Action == FileMove)   ActionCode = Move_To_OTG;
    if(self.Target == ExternalStorage && self.Action == FileCopy)   ActionCode = Copy_To_OTG;
    
    if(self.Target == CloudService && self.Action == FileMove)      ActionCode = Move_To_Cloud;
    if(self.Target == CloudService && self.Action == FileCopy)      ActionCode = Copy_To_Cloud;
    
    if(self.Target == PhotoLibrary && self.Action == FileMove)      ActionCode = Move_To_Photo;
    if(self.Target == PhotoLibrary && self.Action == FileCopy)      ActionCode = Copy_To_Photo;

    ProcessStatusAlertView = [UIAlertController alertControllerWithTitle:@"Process progress"
                                                                 message:@""
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    ConfirmBtn = [UIAlertAction actionWithTitle:@"Confirm"
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                 {
                     [self.navigationController popViewControllerAnimated:YES];
                 }];
    
    ProcessFinishAlertView = [UIAlertController alertControllerWithTitle:@"Process finished"
                                                                 message:@""
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [ProcessFinishAlertView addAction:ConfirmBtn];
    
    FileList = [[NSMutableArray alloc] init];
    
    [self initParameter];
}

- (void)initParameter
{
    PathList    = [[NSMutableArray alloc] init];
    FolderList  = [[NSMutableArray alloc] init];
    FileList    = [[NSMutableArray alloc] init];
    FullList    = [[NSMutableArray alloc] init];
    
    ExistFilePathArray  = [[NSArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    LoadingAlert = [UIAlertController alertControllerWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                       message:[Language get:@"Cloud_msg3" alter:@"Retrive file list"]
                                                preferredStyle:UIAlertControllerStyleAlert];
    
    
    switch (self.Target)
    {
        case ExternalStorage:
        {
            nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
        
            if([nsmaAccessoryList count] <= 0)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                [self changeViewInitOTG];
                [PathList addObject:@"/"];
                [self getOTGFileList:@"/"];
            });
            
            break;
        }
        case CloudService:
            restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
            [restClient setDelegate:self];
            
            if (![[DBSession sharedSession] isLinked])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                PathList = [[NSMutableArray alloc] init];
                
                [PathList addObject:@"/"];
                
                NSString *CloudPathList = [self CombinationFullPath];
                
                NSLog(@"%@",CloudPathList);
                
                [restClient loadMetadata:CloudPathList];
                
                [self presentViewController:LoadingAlert animated:YES completion:nil];
            }
            
        case PhotoLibrary:
            //TODO:From Photo Center
            
        default:
            break;
    }
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    fsaAPI = nil;
    OTAISP = nil;
    
    //unregister disconnect
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
}

- (IBAction)BackToPrev:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview Controller

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return FileList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FileTableViewCell *Cell = (FileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:FileCellIdentifier];
    
    if (Cell == nil)
    {
        Cell = [[FileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:FileCellIdentifier];
    }
    
    File *cFile = FileList[indexPath.row];
    
    
    if(cFile.FileType == eFOLDER)
    {
        [Cell.Thumbnail setImage:[UIImage imageNamed:@"Folder_icon"]];
        [Cell.Filename setText:cFile.FileName];
        [Cell.Filesize setHidden:true];
    }
    else
    {
        UIImage *FileThumb = [FileType getThumbnail:cFile.FileExtension ImageSize:YES];
        
        [Cell.Thumbnail setImage:FileThumb];
        
        [Cell.Filename setText:[[NSString alloc] initWithFormat:@"%@.%@" ,cFile.FileName ,cFile.FileExtension]];
    }
    
    [Cell setTintColor:[UIColor blueColor]];
    
    [Cell setAccessoryType:UITableViewCellAccessoryNone];
    
    [Cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return Cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    File *cFile = FileList[indexPath.row];
    NSMutableString *DestPath = [[NSMutableString alloc] init];
    
//    if(!PathList)
//    {
//        PathList = [[NSMutableArray alloc] init];
//    }
    
    switch (self.Target)
    {
        case ExternalStorage:
        {
            if ([cFile.FileName isEqualToString:@"..."])
            {
                [PathList removeLastObject];
                
//                NSString *FolderPath = [self CombinationFullPath];
//                
//                [self getOTGFileList:FolderPath];
            }
//            else if (cFile.FileType == eFOLDER)
            else
            {
                [PathList addObject: cFile.FileName];
                
//                self.title = [NSString stringWithFormat:@"PathList.count = %d : %@",PathList.count,cFile.FileName];
//                
//                [self getOTGFileList:[self CombinationFullPath]];
            }
            
            if (PathList.count > 0)
            {
                for (int i = 0 ; i < PathList.count ; i++)
                {
                    [DestPath appendString:PathList[i]];
                    
                    if (![PathList[i] isEqualToString:@"/"] && i < PathList.count -1)
                    {
                        [DestPath appendString:@"/"];
                    }
                }
            }
            else
            {
                [DestPath appendString:@"/"];
            }
            
            [self getOTGFileList:DestPath];
            
//            self.title = DestPath;
            
            LoadingAlert = [UIAlertController alertControllerWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                               message:[Language get:@"Cloud_msg2" alter:@"Retrive external storage file list"]
                                                        preferredStyle:UIAlertControllerStyleAlert];
            
            break;
        }
        case CloudService:
        {
            if ([cFile.FileName isEqualToString:@"..."])
            {
                [PathList removeLastObject];
                
                for (int i = 0 ; i < PathList.count ; i++)
                {
                    [DestPath appendString:PathList[i]];
                    
                    if (![PathList[i] isEqualToString:@"/"])
                    {
                        [DestPath appendString:@"/"];
                    }
                }
            }
            else
            {
                [PathList addObject:cFile.FileName];
                
                if (PathList.count > 0)
                {
                    for (int i = 0 ; i < PathList.count ; i++)
                    {
                        [DestPath appendString:PathList[i]];
                        
                        if (![PathList[i] isEqualToString:@"/"])
                        {
                            [DestPath appendString:@"/"];
                        }
                    }
                }
                else
                {
                    [DestPath appendString:@"/"];
                }
            }
            
            LoadingAlert = [UIAlertController alertControllerWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                               message:[Language get:@"Cloud_msg4" alter:@"Retrive cloud file list"]
                                                        preferredStyle:UIAlertControllerStyleAlert];
            
            [restClient loadMetadata:DestPath];
            
            break;
        }
    }
    
    
    
    [self presentViewController:LoadingAlert animated:YES completion:nil];
}

-(void) CopyFilesToPhotoCenter:(NSArray*)TargetFiles
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        for(int i = 0 ; i < TargetFiles.count ; i++)
        {
            [fsaAPI CopyFileOTGtoDevice:COPY_OTG_TO_ALBUM
                                SrcPath:(NSString*)TargetFiles[i]];
        }
        
        //TODO:Progress bar
    });
}

#pragma mark - UI Controller
- (IBAction)SelectDoneBtn:(id)sender
{
    switch (self.Source)
    {
        case ExternalStorage:
        {
            switch (self.Target)
            {
                case CloudService:
                    
                    break;
                case PhotoLibrary:
                    break;
            }
            break;
        }
        case CloudService:
        {
            //TODO:Download file from Cloud
            
            
            switch (self.Action)
            {
                case FileMove:
                    break;
                case FileCopy:
                    for (int i = 0 ; i < TargetFiles.count ; i++)
                    {
                        [self CopyFileToOTG:TargetFiles[i] DestPath:@"/"];
                    }
                    break;
            }
            
            break;
        }
        case PhotoLibrary:
        {
            switch (self.Target)
            {
                case CloudService:
                {
                    if(self.Action == FileCopy)
                    {
                        [self CopyToCloud];
                    }
                    break;
                case ExternalStorage:
                    break;
                }
            }
            
            break;
        }
    }
    
    switch (ActionCode)
    {
        case Move_To_OTG:
            break;
            
        default:
            break;
    }
}

#pragma mark - Cloud Operation
- (void) Upload_Photo_To_Cloud : (ALAsset *) PhotoALAsset
                   Destination : (NSString*) DestPath
{
    ALAssetRepresentation *ALAssetRep = [PhotoALAsset defaultRepresentation];
    
    NSString    *Photo_FileName = [ALAssetRep filename];
    
    NSArray     *AppFolderPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString    *PhotoAbsolutePath = [NSString stringWithFormat:@"%@%@",[AppFolderPaths firstObject],Photo_FileName];
    
    NSString    *PhotoExtensionName = [[Photo_FileName pathExtension] lowercaseString];
    
    UIImage     *ImageBuffer = [UIImage imageWithCGImage:[[PhotoALAsset defaultRepresentation]fullScreenImage]];
    NSData      *Photo_NSData;
    
    if ([PhotoExtensionName isEqualToString:@"jpg"])
        Photo_NSData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(ImageBuffer,1)];
    else
        Photo_NSData = [[NSData alloc] initWithData:UIImagePNGRepresentation(ImageBuffer)];
} 

- (void) CopyToCloud
{
    NSLog(@"Upload to Cloud");
    
    int index;
    
    if(self.Source == PhotoLibrary)
    {
        NSString *DisplayMessage = [NSString stringWithFormat:@"Uploading %2d file to 'Dropbox'",TargetFiles.count];
        
        [ProcessStatusAlertView setMessage:DisplayMessage];
        
        [self presentViewController:ProcessStatusAlertView
                           animated:YES
                         completion:nil];
        
        ProcessIndex = 0;
        
        for( ALAsset *PhotoAsset in TargetFiles)
        {
            NSData *RawData = [Common ConvertALAssetToNSData:PhotoAsset];
            
            NSString *FilePath = [Common SaveNSDataToLocalAppFolder:[[PhotoAsset defaultRepresentation] filename]
                                                            RawData:RawData];
            
            NSLog(@"FilePath:%@",FilePath);
            
            BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:FilePath];
            
            if (fileExist)
            {
                [restClient uploadFile:[[PhotoAsset defaultRepresentation] filename]
                                toPath:[self CombinationFullPath]
                         withParentRev:nil
                              fromPath:FilePath];
            }
            else
            {
                NSLog(@"%@ do not exist",FilePath);
            }
        }
    }
}

#pragma mark Dropbox API
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    FileList = [[NSMutableArray alloc] init];
    
    if (!metadata.isDirectory)
        return;
    
    
    NSLog(@"Folder '%@' contains:", metadata.path);
    
    if (PathList.count > 1)
    {
        File *prePath = [[File alloc] init];
        prePath.FileName = @"...";
        prePath.FileExtension = NULL;
        prePath.FileType = (CATEGORY*)eFOLDER;
        
        [FileList addObject:prePath];
    }
    
    NSMutableString *cFilePath = [[NSMutableString alloc] init];
    
    for (int i = 0 ; i < PathList.count ; i++)
    {
        if (![PathList[i] isEqualToString:@"/"])
        {
            [cFilePath appendString: PathList[i]];
            [cFilePath appendString:@"/"];
        }
    }
    
    for (DBMetadata *file in metadata.contents)
    {
        //Filename Preprocess
        NSString *Temp_Filename = file.filename;
        
        File *cFile = [[File alloc] initWithFilePath:file.filename];
        
        //It's folder
        if ([Temp_Filename rangeOfString:@"."].location == NSNotFound)
        {
            NSLog(@"FileName:%@",file.filename);
            
            cFile.FileName = file.filename;
            cFile.FileExtension = NULL;
            cFile.FileType = (CATEGORY*)eFOLDER;
            cFile.FilePath = @"";
            
            [FileList addObject:cFile];
        }
    }
    
    if(![[NSThread currentThread] isMainThread])
    {
        [self performSelector:@selector(reloadData)
                     onThread:[NSThread mainThread]
                   withObject:self.TagetBrowserTableView
                waitUntilDone:NO];
    }
    [self.TagetBrowserTableView reloadData];
    
    [LoadingAlert dismissViewControllerAnimated:YES completion:nil];
}

- (void)restClient:(DBRestClient *)client
      uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath
          metadata:(DBMetadata *)metadata
{
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    
    ProcessIndex += 1;
    
    if(ProcessIndex == TargetFiles.count)
    {
        [ProcessStatusAlertView dismissViewControllerAnimated:YES completion:nil];
        
        [ProcessFinishAlertView setMessage:[NSString stringWithFormat:@"%2d files has been processed",ProcessIndex]];
        
        [self presentViewController:ProcessFinishAlertView
                           animated:YES
                         completion:nil];
    }
    
    NSLog(@"ProcessIndex:%d",ProcessIndex);
    
//    NSString *DisplayMessage = [NSString stringWithFormat:@"Uploading file to 'Dropbox' %2d / %2d",ProcessIndex,TargetFiles.count];
    
//    [ProcessStatusAlertView setMessage:DisplayMessage];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    NSString *debugMessage = [NSString stringWithFormat:@"%@",error];
    
    UIAlertView *errorNotify = [[UIAlertView alloc] initWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                          message:debugMessage
                                                         delegate:self
                                                cancelButtonTitle:[Language get:@"PhotoCenter_OK" alter:@"OK"]
                                                otherButtonTitles:nil];
    
    [errorNotify show];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Error loading metadata: %@", error);
}


- (NSString *) CombinationFullPath : (NSString*) FileName
{
    NSMutableString *_FilePath = [[NSMutableString alloc] init];
    
    if([PathList[PathList.count-1] isEqualToString: @"/"] && !FileList)
    {
        return @"/";
    }
    
    for (int i = 0 ; i < PathList.count ; i++)
    {
        [_FilePath appendString:PathList[i]];
        [_FilePath appendString:@"/"];
    }
    
    [_FilePath appendString:FileName];
    
    return _FilePath;
}

- (NSString *) CombinationFullPath
{
    NSMutableString *_FilePath = [[NSMutableString alloc] init];
    
    if([PathList[PathList.count-1] isEqualToString: @"/"])
    {
        return @"/";
    }
    
    for (int i = 0 ; i < PathList.count ; i++)
    {
        [_FilePath appendString:PathList[i]];
        [_FilePath appendString:@"/"];
    }
    
    return _FilePath;
}

#pragma mark - External Storage
- (void) changeViewInitOTG
{
    if(fsaAPI == nil){
        fsaAPI = [[FileSystemAPI alloc] init:self];
        fsaAPI.delegateForAPI = self;
    }
}

- (void) getOTGFileList:(NSString *) Path
{
    FileList = [[NSMutableArray alloc] init];
    
    __block File *tempFile = [File alloc];
    
    if(PathList.count > 1)
    {
        File *ParentFolder = [[File alloc] initWithFilePath:@"..."];
        [FileList addObject:ParentFolder];
    }
    
    NSMutableString *debug = [[NSMutableString alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSMutableArray *nsfProertys = [[NSMutableArray alloc] init];
        
        nsfProertys = [fsaAPI doListOTGFile:PATH_ABSOLUTE path:Path];

        for(int i = 0; i < nsfProertys.count; i++)
        {
            NSString *str = [nsfProertys objectAtIndex:i];
            NSString *strTmp = [str substringToIndex:1];
            if (![strTmp isEqual: @"."])
            {
                if ((i%2)==0)
                {
                    tempFile = [[File alloc] initWithFilePath:str FirstDate:@"2015/10/21"];
                    
                    tempFile.FilePath = [NSString stringWithFormat:@"%@/%@",Path,str];
                    
                    if(tempFile.FileType == eFOLDER)
                    {
                        [FileList addObject:tempFile];
                    }
                }
            }
            else
            {
                i++;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.TagetBrowserTableView reloadData];
            [LoadingAlert dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

-(void) CopyFileToOTG : (NSString *)FilePath DestPath:(NSString *)TargetPath
{
    NSString *FileName = [[FilePath lastPathComponent] stringByDeletingPathExtension];
    
    
    
    [fsaAPI doWriteFileToOTG:FilePath
                    fileName:[NSString stringWithFormat:@"%@%@",TargetPath,FileName]];
    
    [self ShowMessage:@"System Message"
              Message:[NSString stringWithFormat:@"File: %@ \ncopied to 'OTG'",FilePath]];
}

-(bool) CopyToOTG : (NSString *)PhotoName
{
    NSString *DestFile = [NSString stringWithFormat:@"/%@",PhotoName];
    
//    UIImage *DestPhoto = [UIImage imageWithCGImage:self.FullPhoto.image.CGImage];
    
    __block NSString *Extension = [[DestFile pathExtension] uppercaseString];
    
    if(![Extension isEqualToString:@"JPG"] && ![Extension isEqualToString:@"PNG"])
    {
        UIAlertView *WarningMsg = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_error_msg4" alter:@"Warning"]
                                                             message:[Language get:@"Cloud_error_msg5" alter:@"Format is not support"]
                                                            delegate:self
                                                   cancelButtonTitle:[Language get:@"PhotoCenter_OK" alter:@"OK"]
                                                   otherButtonTitles:nil];
        [WarningMsg show];
        
        return false;
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        
//        if([Extension isEqualToString:@"JPG"])
//        {
//            [fsaAPI doWriteImageToOTG:JPG
//                                Image:DestPhoto
//                             fileName:DestFile];
//        }
//        else if([Extension isEqualToString:@"PNG"])
//        {
//            [fsaAPI doWriteImageToOTG:PNG
//                                Image:DestPhoto
//                             fileName:DestFile];
//        }
//    });
    
    return true;
}

#pragma mark - External Storage Delegate
- (void)accessoryDidDisconnect : (NSNotification *)notification
{
    fsaAPI = nil;
    OTAISP = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma Cloud 

#pragma mark - Debug

- (void) debugMessage:(NSString *) Message
{
    debug = [[UIAlertView alloc] initWithTitle:[Language get:@"PhotoCenter_Message" alter:@"System Message"]
                                                    message:Message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [debug show];
}

- (void)ShowMessage:(NSString*)Title Message:(NSString*)Message
{
    UIAlertView *sysMessage = [[UIAlertView alloc] initWithTitle:Title
                                                         message:Message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    
    [sysMessage show];
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
