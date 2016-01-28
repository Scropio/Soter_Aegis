//
//  CloudFileListViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/9/18.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "CloudFileListViewController.h"
#import "File.h"
#import "RDActionSheet.h"
#import "FileType.h"
#import "CloudDetailViewController.h"
#import "FileTableViewCell.h"
#import "Common.h"
#import "Language.h"
#import "LanguageViewController.h"


@interface CloudFileListViewController () 
{
    NSMutableArray *PathList;
    NSMutableArray *FileList;
    DBRestClient *restClient;
    
    FileType *FileThumbnail;
    
    NSInteger SelectIndex;
    
    Boolean MultiSelectOn;
    
    UIAlertController *LoadingAlert;
    
    NSMutableArray  *selectedArray;
    
    NSMutableArray *ProcessFilePathArray;
    
    //OTG
    NSMutableArray *nsmaAccessoryList;
    NSArray *nsaProtocolString;
    
    //Popup View
    bool OTG_Plugin;
    bool Internet;
    bool Cloud;
    
    UIBarButtonItem *MultiSelectBtn;
    UIBarButtonItem *SelectBtn;
    UIBarButtonItem *DeSelectBtn;
    UIBarButtonItem *DoneBtn;
    UIBarButtonItem *CancelBtn;
    
    UIAlertController *OptionAlert;
        UIAlertAction *MoveBtn;
        UIAlertAction *CopyBtn;
        UIAlertAction *OptionCancelBtn;
    
    UIAlertController *TargetAlert;
        UIAlertAction *OTGBtn;
        UIAlertAction *PhotoBtn;
        UIAlertAction *TargetCancelBtn;
    
    int Action;
    int Target;
    
    int DownloadFileCount;
    
    Common *CommonFunc;
    
}
@end

@implementation CloudFileListViewController

static NSString *FileCellIdentifier = @"FileCell";

#pragma mark - View Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initValue];
    
    [self initSetting];
    
    [self TableviewInitSetting];
    
    [PathList addObject:@"/"];
    
    MultiSelectBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MultiSelect"]
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(MultiSelectBtnClick:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:MultiSelectBtn,nil];
    
    
    [self PopupAlertViewConfig];
}

-(void) initValue
{
    FileList = [[NSMutableArray alloc] init];
    PathList = [[NSMutableArray alloc] init];
    
    selectedArray = [[NSMutableArray alloc] init];
    ProcessFilePathArray = [[NSMutableArray alloc] init];
}

-(void) initSetting
{
    [self.CloudFileList setDataSource:self];
    [self.CloudFileList setDelegate:self];
    
    restClient = [[DBRestClient alloc] initWithSession: [DBSession sharedSession]];
    restClient.delegate = self;
    
    [self CheckDropboxAuthentication];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.view setTintColor:[UIColor whiteColor]];
}

-(void) SetBackgroundImage
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

-(void) TableviewInitSetting
{
    [self.CloudFileList registerNib:[UINib nibWithNibName:@"FileCellView"
                                                   bundle:nil]
             forCellReuseIdentifier:FileCellIdentifier];
    
    MultiSelectOn = false;
    
    [self.CloudFileList setAllowsMultipleSelection:MultiSelectOn];
}

-(void) CheckDropboxAuthentication
{
    if (![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
        
        UIAlertView *ErrorMsg;
        
        ErrorMsg = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                              message:[Language get:@"Cloud_error_msg3" alter:@"Authentication error:please check your dropbox service"]
                                             delegate:self
                                    cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                    otherButtonTitles:nil];
        
        [ErrorMsg show];
        
        [self dismissViewControllerAnimated:NO completion:nil];
        
        return;
    }
    else
    {
        NSLog(@"Dropbox is Linked");
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [self UpdateData];

    if ([self.CloudFileList indexPathForSelectedRow]) {
        
        [self.CloudFileList deselectRowAtIndexPath:[self.CloudFileList indexPathForSelectedRow]
                                          animated:YES];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    LoadingAlert = [UIAlertController alertControllerWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                                       message:[Language get:@"Cloud_msg" alter:@"Retrive cloud file list"]
                                                preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:LoadingAlert animated:YES completion:nil];
    
    [restClient loadMetadata:[self CombinationFullPath:@""]];
}


#pragma mark TableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return FileList.count;
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
    
//    NSLog(@"%@",[[NSString alloc] initWithFormat:@"%@.%@" ,cFile.FileName ,cFile.FileExtension]);
    
    if(cFile.FileType == eFOLDER)
    {
        [Cell.Thumbnail setImage:[UIImage imageNamed:@"Folder_icon"]];
        [Cell.Filename setText:cFile.FileName];
    }
    else
    {
        UIImage *FileThumb = [FileType getThumbnail:cFile.FileExtension ImageSize:YES];
        [Cell.Thumbnail setImage:FileThumb];
        
        [Cell.Filename setText:[[NSString alloc] initWithFormat:@"%@.%@" ,cFile.FileName ,cFile.FileExtension]];
    }
    
    [Cell setTintColor:[UIColor blueColor]];
    
    if([selectedArray containsObject:indexPath])
    {
        [Cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [Cell setAccessoryType:UITableViewCellAccessoryNone];
        
        [Cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    
    
    
    
    if (FileList[indexPath.row])
    
//    if(indexPath.row == FileList.count)
//    {
        [LoadingAlert dismissViewControllerAnimated:YES completion:nil];
//    }
    
//    NSLog(@"%d : %d",indexPath.row,FileList.count);
    
    return Cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    File *cFile = FileList[indexPath.row];
    NSMutableString *DestPath = [[NSMutableString alloc] init];
    
    UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(MultiSelectOn)
    {
        if (cFile.FileType != eFOLDER)
        {
            if (![cFile.FileName isEqualToString:@"..."])
            {
                if(selectCell.accessoryType == UITableViewCellAccessoryNone)
                {
                    [selectedArray addObject:indexPath];
                    [selectCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
                else
                {
                    [selectedArray removeObject:indexPath];
                    [selectCell setAccessoryType:UITableViewCellAccessoryNone];
                }
            }
        }
    }
    else
    {
        if (cFile.FileType == (CATEGORY*)eFILE)
        {
            SelectIndex = indexPath.row;
            [self performSegueWithIdentifier:@"CloudList2FileDetail" sender:self];
        }
        else
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
            
            [restClient loadMetadata:DestPath];
            
            LoadingAlert = [UIAlertController alertControllerWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                                               message:[Language get:@"Cloud_msg" alter:@"Retrive cloud file list"]
                                                        preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:LoadingAlert animated:YES completion:nil];
        }
    }
    
    
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
        [self.CloudFileList reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *Header = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:@"pathHeader"];
    
    [Header setBackgroundColor:RGB(40.0, 114.0, 195.0, 0.8)];
    
    UIFont *HeaderFont = [UIFont fontWithName:@"Helvetica Neue" size:24];
    
    UILabel *PathTitle = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                   0,
                                                                   60,
                                                                   Header.frame.size.height)];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%f",Header.frame.size.width]);
    
    [PathTitle setFont:HeaderFont];
    [PathTitle setText:[Language get:@"Cloud_Path" alter:@"Path:"]];
    [Header addSubview:PathTitle];
    
    UILabel *Path = [[UILabel alloc] initWithFrame:CGRectMake(PathTitle.frame.origin.x + PathTitle.frame.size.width,
                                                              0,
                                                              self.view.bounds.size.width - (PathTitle.frame.origin.x + PathTitle.frame.size.width),
                                                              Header.frame.size.height)];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%f",Header.frame.size.width - PathTitle.frame.size.width]);
    
    [Path setFont:HeaderFont];
    [Path setText:[self CombinationFullPath]];
    
    [Path setBackgroundColor:[UIColor clearColor]];
    
    [Header addSubview:Path];
    
    NSLog(@"Repaint Header");
    
    return Header;
}

#pragma mark -
#pragma mark Dropbox API

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    if (metadata.isDirectory)
    {
        FileList = [[NSMutableArray alloc] init];
        
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
//            if(![[NSString stringWithFormat:@"%@",PathList[i]] isEqualToString:@"/"])
//            {
            if (![PathList[i] isEqualToString:@"/"])
            {
                [cFilePath appendString: PathList[i]];
                [cFilePath appendString:@"/"];
            }
//            }
        }
        
        for (DBMetadata *file in metadata.contents)
        {
            //Filename Preprocess
            NSString *Temp_Filename = file.filename;
            
            //It's folder
            File *cFile = [[File alloc] initWithFilePath:file.filename];
            
            if ([Temp_Filename rangeOfString:@"."].location == NSNotFound)
            {
                cFile.FileName = file.filename;
                cFile.FileExtension = NULL;
                cFile.FileType = (CATEGORY*)eFOLDER;
                cFile.FilePath = @"";
            }
            else    //It's file
            {
                NSArray *FileSpilt = [file.filename componentsSeparatedByString:@"."];
                
                cFile.FileName = FileSpilt[0];
                cFile.FileExtension = FileSpilt.lastObject;
                cFile.FileExtension = cFile.FileExtension.lowercaseString;
                cFile.FileType = (CATEGORY*)eFILE;
                
                cFile.FilePath = [self CombinationFullPath:file.filename];
                
                NSLog(@"cFile.FilePath=%@",cFile.FilePath);
            }
            
            [FileList addObject:cFile];
        }
        
        if(![[NSThread currentThread] isMainThread])
        {
            [self performSelector:@selector(reloadData)
                         onThread:[NSThread mainThread]
                       withObject:self.CloudFileList
                    waitUntilDone:NO];
        }
        [self.CloudFileList reloadData];
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Error loading metadata: %@", error);
}

#pragma mark -
#pragma mark Operation Func

-(NSString *) CombinationFullPath : (NSString*) FileName
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

-(NSString *) CombinationFullPath
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

- (IBAction) MultiSelectBtnClick:(id)sender
{
//    [self MultiSelectSwitch];
    
    MultiSelectOn = !MultiSelectOn;

    [self.CloudFileList setAllowsMultipleSelection:MultiSelectOn];
    [self.CloudFileList deselectRowAtIndexPath:[self.CloudFileList indexPathForSelectedRow] animated:YES];

    if(MultiSelectOn)
    {

        SelectBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SelectAll"]
                                                     style:UIBarButtonItemStyleDone
                                                    target:self
                                                    action:@selector(SelectAllBtn)];

        DeSelectBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Deselect"]
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(DeselectAllBtn)];

        CancelBtn = [[UIBarButtonItem alloc] initWithTitle:[Language get:@"Cloud_Cancel" alter:@"Cancel"]
                                                     style:UIBarButtonItemStyleDone
                                                    target:self
                                                    action:@selector(CancelBtn)];

        DoneBtn = [[UIBarButtonItem alloc] initWithTitle:[Language get:@"Cloud_Done" alter:@"Done"]
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(DoneBtn)];

        [self.navigationItem setHidesBackButton:YES];

        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:DoneBtn,CancelBtn,nil];

        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:SelectBtn,DeSelectBtn,nil];
    }
    else
    {
        [selectedArray removeAllObjects];

        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:MultiSelectBtn,nil];
        
        self.navigationItem.leftBarButtonItems = nil;
        
        [self.navigationItem setHidesBackButton:NO];
    }
}

-(void) CancelBtn
{
    [self DeselectAllBtn];
    MultiSelectOn = true;
    [self MultiSelectBtnClick:self];
}

-(void) DeselectAllBtn
{
    NSIndexPath *current;
    
    NSLog(@"SelectedArray : %d ", selectedArray.count);
    
//    for (int i = selectedArray.count -1 ; i >= 0 ; i--)
//    {
//        current = selectedArray[i];
//    }
    
    [selectedArray removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.CloudFileList reloadData];
    });
}

-(void) SelectAllBtn
{
    NSIndexPath *current;
    
    for (NSInteger index = 0 ; index < FileList.count ; index++)
    {
        current = [NSIndexPath indexPathForRow:index inSection:0];
        
        File *cFile = FileList[index];
        
        NSLog(@"[%d]:%@",index,cFile.FilePath);
        
        if (cFile.FileType == (CATEGORY*)eFILE)
        {
            [selectedArray addObject:current];
//            NSLog(@"SelectAllBtn:%d",selectedArray.count);
        }
    }
    
    //For Debug
    NSLog(@"-------------------------------------");
    for (NSInteger i = 0 ; i < selectedArray.count ; i++)
    {
        current = selectedArray[i];
        
        File *cFile = FileList[current.row];
        
        NSLog([NSString stringWithFormat:@"[%d] : %@",i,cFile.FilePath]);
    }
    NSLog(@"-------------------------------------");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.CloudFileList reloadData];
    });
}

-(void) DoneBtn
{
    [self presentViewController:OptionAlert animated:YES completion:nil];
}

#pragma mark Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CloudDetailViewController *Cloud_Detail_View = (CloudDetailViewController *) [segue destinationViewController];
    
    
    if ([[segue identifier] isEqualToString:@"CloudList2FileDetail"])
    {
        Cloud_Detail_View.CurrentFile = (File *)FileList[SelectIndex];
    }
    
    if([[segue identifier] isEqualToString:@"Cloud_List_To_File_Browser"])
    {
        FileBrowserIntegrateTableViewController *TargetSelectView =
                        (FileBrowserIntegrateTableViewController *) [segue destinationViewController];
        
        TargetSelectView.Source = CloudService;
        TargetSelectView.Target = Target;
        TargetSelectView.Action = Action;
        
        TargetSelectView.TargetFiles = ProcessFilePathArray;
    }
    
}

#pragma mark -
#pragma mark Warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ShowMsg
{
    NSLog(@"=============ShowMsg=============");
}

#pragma mark - program login function
-(void) UpdateDeviceStatus
{
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    OTG_Plugin  = ([nsmaAccessoryList count] != 0      ? (true) : (false));
    Internet    = ([Common CheckInternet]              ? (true) : (false));
    Cloud       = ([[DBSession sharedSession] isLinked]? (true) : (false));
}

-(RDActionSheet*) RDActionOptionProcessor:(NSString *)Title
                             CancelButton:(NSString *)BtnText
{
    [self UpdateDeviceStatus];
    
    NSLog(@"%d %d %d",OTG_Plugin,Internet,Cloud);
    
    RDActionSheet *actionSheet;
    
    if(OTG_Plugin && (Internet && Cloud))
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:Title
                                         cancelButtonTitle:BtnText
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"Cloud_OTG" alter:@"OTG"],[Language get:@"Cloud_Cloud" alter:@"Cloud"],nil];
    }
    
    if(OTG_Plugin && !(Internet && Cloud))
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:Title
                                         cancelButtonTitle:BtnText
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"Cloud_OTG" alter:@"OTG"],nil];
    }
    
    if(!OTG_Plugin && (Internet && Cloud))
    {
        actionSheet = [[RDActionSheet alloc] initWithTitle:Title
                                         cancelButtonTitle:BtnText
                                        primaryButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:[Language get:@"Cloud_Cloud" alter:@"Cloud"],nil];
    }
    
    return actionSheet;
}

#pragma mark -
#pragma mark - Popup AlertView
-(void) PopupAlertViewConfig
{
    MoveBtn = [UIAlertAction actionWithTitle:[Language get:@"Cloud_Move" alter:@"Move"]
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
               {
                   Action = FileMove;
                   
                   [self UpdateDeviceStatus];
                   
                   [OTGBtn setEnabled:OTG_Plugin];
                   
                   [PhotoBtn setEnabled:(Internet && Cloud)];
                   
                   [self presentViewController:TargetAlert animated:YES completion:nil];
               }];
    
    CopyBtn = [UIAlertAction actionWithTitle:[Language get:@"Cloud_Copy" alter:@"Copy"]
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                       {
                                           Action = FileCopy;
                                           
                                           [self UpdateDeviceStatus];
                                           
                                           [OTGBtn setEnabled:OTG_Plugin];
                                           
                                           [PhotoBtn setEnabled:(Internet && Cloud)];
                                           
                                           [self presentViewController:TargetAlert animated:YES completion:nil];
                                       }];
    
    OTGBtn =  [UIAlertAction actionWithTitle:@"External Storage"
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                       {
                                           Target = ExternalStorage;
                                           
                                           [self downloadFileFromCloudToLocal:selectedArray];
                                           
                        //                   [self performSegueWithIdentifier:@"Cloud_List_To_File_Browser"
                        //                                             sender:self];
                                       }];
    
    PhotoBtn = [UIAlertAction actionWithTitle:@"Photo Center"
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                {
                    Target = PhotoLibrary;
                    
                    [self downloadFileFromCloudToLocal:selectedArray];
                }];
    
    OptionCancelBtn = [UIAlertAction actionWithTitle:[Language get:@"Cloud_Cancel" alter:@"Cancel"]
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action)
                       {
                           Target = -1;
                           Action = -1;
                           
                           [self MultiSelectBtnClick:self];
                       }];
    
    TargetCancelBtn = [UIAlertAction actionWithTitle:[Language get:@"Cloud_Cancel" alter:@"Cancel"]
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action)
                       {
                           [self presentViewController:OptionAlert animated:YES completion:nil];
                       }];
    
    
    OptionAlert = [UIAlertController alertControllerWithTitle:[Language get:@"Cloud_AlertView_msg2" alter:@"Action Option"]
                                                      message:@""
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    [OptionAlert addAction:MoveBtn];
    [OptionAlert addAction:CopyBtn];
    [OptionAlert addAction:OptionCancelBtn];
    
    TargetAlert = [UIAlertController alertControllerWithTitle:[Language get:@"Cloud_AlertView_msg1" alter:@"Select Target"]
                                                      message:@""
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    [TargetAlert addAction:OTGBtn];
    [TargetAlert addAction:PhotoBtn];
    [TargetAlert addAction:TargetCancelBtn];
}

//Input: FilePathArray  OutPut: Downloaded File Path Array
- (void)downloadFileFromCloudToLocal:(NSArray*) FileArray
{
    BOOL fileExist = false;
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *oFilePath;
    
    DownloadFileCount = FileArray.count;
    
    for(int i = 0 ; i < FileArray.count ; i++)
    {
        NSIndexPath *_Pos = FileArray[i];
        
        File *_File = FileList[_Pos.row];
        
        oFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",_File.FileName,_File.FileExtension]];
        
//        oFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_File.FileName]];
        
        fileExist = [[NSFileManager defaultManager] fileExistsAtPath:oFilePath];
        
        if(!fileExist)
        {
            [restClient loadFile:_File.FilePath intoPath:oFilePath];
            
            NSLog(@"File not exist:%@",_File.FilePath);
        }
        else
        {
            NSLog(@"File exist:%@",oFilePath);
            
            NSString *str = [NSString stringWithFormat:@"'downloadFileFromCloudToLocal'\nFile exist at path: %@",oFilePath];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                                            message:str
                                                           delegate:self
                                                  cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                                  otherButtonTitles:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
            
            DownloadFileCount = DownloadFileCount - 1;
            
            [ProcessFilePathArray addObject:oFilePath];
        }
    }
    
    [self ProcessWhileFileIsReady];
    
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    NSLog(@"File loaded into path: %@", localPath);
    
    NSString *str = [NSString stringWithFormat:@"File downloaded to path: %@",localPath];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Language get:@"Cloud_Message" alter:@"System Message"]
                                                    message:str
                                                   delegate:self
                                          cancelButtonTitle:[Language get:@"Cloud_OK" alter:@"OK"]
                                          otherButtonTitles:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
    
    DownloadFileCount = DownloadFileCount - 1;
    
    [ProcessFilePathArray addObject:localPath];
    
    [self ProcessWhileFileIsReady];
}

- (void)ProcessWhileFileIsReady
{
    if(DownloadFileCount == 0)
    {
        if(Target == PhotoLibrary)
        {
            NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *oFilePath;
            
            for(int i = 0 ; i < selectedArray.count ; i++)
            {
                NSIndexPath *_Pos = selectedArray[i];
                
                File *_File = FileList[_Pos.row];
                
                oFilePath = [documentsDirectory stringByAppendingPathComponent:_File.FilePath];
                
                if(![Common isValidPhoto:_File.FileExtension])
                {
                    continue;
                }
                
                [self CopyToPhotoCenter:oFilePath];
                
                NSLog(@"Copied file to 'PhotoCenter':%@",oFilePath);
                
                if(Action == FileMove)
                {
                    [restClient deletePath:_File.FilePath];
                }
            }
            
            [restClient loadMetadata:[self CombinationFullPath:@""]];
        }
        else
        {
//            self.title = @"Colud Downloaded";
            
            [self performSegueWithIdentifier:@"Cloud_List_To_File_Browser"
                                      sender:self];
        }
    }
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    NSLog(@"There was an error loading the file: %@", error);
}

- (void)CopyFilesToPhotoCenter
{
    for (int i = 0 ; i < ProcessFilePathArray.count ; i++)
    {
        [self CopyToPhotoCenter:ProcessFilePathArray[i]];
        NSLog(@"Copy %@ to PhotoCenter",ProcessFilePathArray[i]);
    }
}

- (void)CopyToPhotoCenter:(NSString *)fileName
{
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];
    
    UIImage* image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    
    NSLog(@"%@",[NSString stringWithFormat:@"CopyToPhoto:%@",fileName]);
}

- (void)PrepareFilePathArray:(NSMutableArray *)SelectFileArray
{
    NSIndexPath *_CurrentIndex;
    
    for (int i = 0 ; i < selectedArray.count ; i++)
    {
        _CurrentIndex = selectedArray[i];
        File *cFile = FileList[_CurrentIndex.row];
        
        
    }
}


//
//
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//
//}

#pragma mark update data
-(void)UpdateData
{
    self.title = [Language get:@"Cloud_Title" alter:@"Cloud List"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"Cloud_Title" alter:@"Cloud List"];
    
    
    
}

@end
