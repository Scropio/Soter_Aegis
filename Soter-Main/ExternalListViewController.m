//
//  ExternalListViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/7/6.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "ExternalListViewController.h"
#import "FileSystemAPI.h"
#import <iFDiskSDK_iap2/iFDiskSDK_iap2.h>
#import "File.h"
#import "ExternalFileInfoViewController.h"
#import "Language.h"
#import "LanguageViewController.h"

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width

@interface ExternalListViewController ()
{
    FileSystemAPI *fsaAPI;
    EADSessionController *escSessionController;
    OTAController *OTAISP;
    
    NSMutableArray *nsmaAccessoryList;
    NSArray *nsaProtocolString;
    
//    UIView *BottomMenu;
    
    NSMutableArray *FileList;
    NSMutableArray *FolderList;
    NSMutableArray *FullList;
    
    __block NSMutableData *OTGFile;
    
    int SelectIndex;
    
    NSMutableArray  *selectedArray;
    
    Boolean MultiSelectOn;
    
    //Popup View
    bool OTG_Plugin;
    bool Internet;
    bool Cloud;
    
    UIBarButtonItem *HomeBtn;
    
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
        UIAlertAction *CloudBtn;
        UIAlertAction *PhotoBtn;
        UIAlertAction *TargetCancelBtn;
    
    int Action;
    int Target;
}
@end

@implementation ExternalListViewController

static NSMutableArray *PathList;

bool BottomMenuIsShow = false;
NSString *Identifier = @"FileCell";
UIAlertView *ShowAlert;

#pragma mark - ViewDelegate
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initValue];
    
    [self initSetting];
    
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDidDisconnect:)
                                                 name:EAAccessoryDidDisconnectNotification
                                               object:nil];
    
    if([nsmaAccessoryList count] != 0)
    {
        
        [PathList addObject:@"/"];
        [self.BottomMenu setAlpha:0];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    [self initSetting];
    
    MultiSelectBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MultiSelect"]
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector(MultiSelectBtnClick:)];
    
    HomeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home"]
                                               style:UIBarButtonItemStyleDone
                                              target:self
                                              action:@selector(HomeBtnClick:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:MultiSelectBtn,nil];
    self.navigationItem.leftBarButtonItem = HomeBtn;
    
    [self PopupAlertViewConfig];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self UpdateData];
    
}


-(void) initValue
{
    FileList        = [[NSMutableArray alloc] init];
    FolderList      = [[NSMutableArray alloc] init];
    FullList        = [[NSMutableArray alloc] init];
    PathList        = [[NSMutableArray alloc] init];
    
    selectedArray   = [[NSMutableArray alloc] init];
}

-(void) initSetting
{
    MultiSelectOn = false;
    [self.Table_FileList setAllowsMultipleSelection:MultiSelectOn];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self setLoading:true];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self changeViewInitOTG];
        [self getFileList: [self CombinationPathFromList]];
    });
}

- (void) accessoryDidDisconnect:(NSNotification *)notification
{
    [FullList removeAllObjects];
    
    [self.Table_FileList reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refresh:(id)sender
{
    [self.Table_FileList reloadData];
}

-(void) viewDidDisappear:(BOOL)animated
{
    fsaAPI = nil;
}

#pragma mark - OTG Function
//================================================================================
//Initial OTG first after change view
//Ray 20150807
- (void)changeViewInitOTG {
    if(fsaAPI == nil){
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //dispatch_async(dispatch_get_main_queue(), ^{
        fsaAPI = [[FileSystemAPI alloc] init:self];
        //});
        fsaAPI.delegateForAPI = self;
    }
}

-(NSMutableArray *) getFileList:(NSString *) Path
{
    [FileList removeAllObjects];
    [FolderList removeAllObjects];
    [FullList removeAllObjects];
    
    __block File *tempFile = [File alloc];
    
    if(PathList.count > 1)
    {
        File *ParentFolder = [[File alloc] initWithFilePath:@"..."];
        [FullList addObject:ParentFolder];
    }
    
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
                    //File Name
//                    tempFile = [[File alloc] initWithFilePath:str];
                    tempFile = [[File alloc] initWithFilePath:str FirstDate:@"2015/10/21"];
                    
                    tempFile.FilePath = [NSString stringWithFormat:@"%@/%@",Path,str];

                    if(tempFile.FileType == eFOLDER)
                    {
                        [FolderList addObject:tempFile];
                    }
                    else
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
        
        [FullList addObjectsFromArray:FolderList];
        [FullList addObjectsFromArray:FileList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.Table_FileList reloadData];
//            [self setLoading:false];
        });

    });
    
    return nil;
}

#pragma mark- TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectIndex = (int)indexPath.row;
    
    File* cFile = FullList[indexPath.row];
    
    if ([cFile.FileName isEqualToString:@"..."])
    {
//        FullList = [[NSMutableArray alloc]init];
//        
//        if (PathList.count > 1)
//        {
//            File *ParentFolder = [[File alloc] initWithFilePath:@"..."];
//            [FullList addObject:ParentFolder];
//        }
        
        //Ray 20150924
        //For return last page
        //Double remove("/"+folder)
        [PathList removeLastObject];
        
        NSString *FolderPath = [self CombinationPathFromList];
        
        [self getFileList:FolderPath];
        
//        return;
    }
    else if (cFile.FileType == eFOLDER)
    {
//        FullList = [[NSMutableArray alloc]init];
//        
//        File *ParentFolder = [[File alloc] initWithFilePath:@"..."];
//        
//        [FullList addObject:ParentFolder];
        
        [PathList addObject: [NSString stringWithFormat:@"%@",cFile.FileName]];
        
        //Ray 20150924
//        [PathList removeLastObject];
        
//        NSString *FolderPath = [self CombinationPathFromList];
        
         [self getFileList:[self CombinationPathFromList]];
        
        //Ray 20150924
        //For folder
        
//        [PathList addObject: [NSString stringWithFormat:@"/"]];
    }
    else if(cFile.FileType == (CATEGORY*)eFILE)
    {
        [self.LoadingIndicator startAnimating];
        
        if ([cFile.FileExtension  isEqual: @"png"] ||
            [cFile.FileExtension  isEqual: @"jpg"] ||
            [cFile.FileExtension  isEqual: @"txt"])
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
                OTGFile = [fsaAPI doReadOTGfile:cFile.FilePath];
                
                self.title = cFile.FilePath;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"OTGList2Detail" sender:self];
                });
            });
        }
        else
        {
            [self performSegueWithIdentifier:@"OTGList2Detail" sender:self];
        }
    }
}



#pragma mark - OTG Assist Function
- (NSString *) CombinationPathFromList
{
    NSMutableString *FullPath = [[NSMutableString alloc] init];
    
    for (int i = 0 ; i < PathList.count ; i++)
    {
        [FullPath appendFormat:@"%@",PathList[i]];
    
        if(i > 0 && i < PathList.count -1)
        {
            [FullPath appendFormat:@"/"];
        }
    }
    
    return FullPath;
}

#pragma mark- TableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return FullList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *Cell = [[UITableViewCell alloc] init];
    [Cell setBackgroundColor:[UIColor clearColor]];
    
    File *cFile = FullList[indexPath.row];
    
    UILabel *FileName = [[UILabel alloc]initWithFrame:CGRectMake(84, 10, 250, 40)];
    FileName.text = [[NSString alloc] initWithFormat:@"%@" ,cFile.FileName];
    
    [Cell addSubview:FileName];

    UIImageView *Type = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 64, 64)];
    [Type setImage: [cFile getThumbnail]];
    [Cell addSubview:Type];
    
    if(cFile.FileType != eFOLDER)
    {
        UILabel *FileData = [[UILabel alloc] initWithFrame:CGRectMake(84, 42, 250, 40)];
        FileData.text = [NSString stringWithFormat:@"%@", cFile.FileDate];
        [Cell addSubview:FileData];
    }
    
    if([selectedArray containsObject:indexPath])
    {
        [Cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [Cell setAccessoryType:UITableViewCellAccessoryNone];
        
        [Cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return Cell;
}

#pragma mark- TableView UI Setting
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
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
        [self.Table_FileList reloadData];
    }
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
    [Path setText:[self CombinationPathFromList]];
    
    [Path setBackgroundColor:[UIColor clearColor]];
    
    [Header addSubview:Path];
    
    NSLog(@"Repaint Header");
    
    return Header;
}

#pragma mark -
#pragma mark AlertView Func

- (IBAction) MultiSelectBtnClick:(id)sender
{
    //    [self MultiSelectSwitch];
    
//    self.title = NSString stringWithFormat:@"MultiSelectBtn Click %d",[MultiSelectOn ];
    
    
    MultiSelectOn = !MultiSelectOn;
    
    [self.Table_FileList setAllowsMultipleSelection:MultiSelectOn];
    [self.Table_FileList deselectRowAtIndexPath:[self.Table_FileList indexPathForSelectedRow] animated:YES];
    
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
        
        CancelBtn = [[UIBarButtonItem alloc] initWithTitle:[Language get:@"PhotoCenter_Cancel" alter:@"Cancel"]
                                                     style:UIBarButtonItemStyleDone
                                                    target:self
                                                    action:@selector(CancelBtn)];
        
        DoneBtn = [[UIBarButtonItem alloc] initWithTitle:[Language get:@"PhotoCenter_Done" alter:@"Done"]
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
    MultiSelectOn = true;
    
    [self DeselectAllBtn];
    [self MultiSelectBtnClick:self];
    
    self.navigationItem.leftBarButtonItem = HomeBtn;
}

-(void) DeselectAllBtn
{
    NSIndexPath *current;
    
    NSLog(@"SelectedArray : %d ", selectedArray.count);
    
    [selectedArray removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.Table_FileList reloadData];
    });
}

-(void) SelectAllBtn
{
    NSIndexPath *current;

    for (NSInteger index = 0 ; index < FullList.count ; index++)
    {
        current = [NSIndexPath indexPathForRow:index inSection:0];
        
        File *cFile = FullList[index];
        
        NSLog(@"[%d]:%@",index,cFile.FileName);
        
        if (cFile.FileType == (CATEGORY *)eFILE)
        {
            [selectedArray addObject:current];
            NSLog(@"SelectAllBtn:%d",selectedArray.count);
            self.title = [NSString stringWithFormat:@"SelectAll.File:%d",selectedArray.count];
        }
    }
    
    NSLog(@"-------------------------------------");
    for (NSInteger i = 0 ; i < selectedArray.count ; i++)
    {
        File *cFile = selectedArray[i];
        
        NSLog(@"%@",[NSString stringWithFormat:@"[%d] : %@",i,cFile.FilePath]);
    }
    NSLog(@"-------------------------------------");
    
    NSLog(@"SelectAllBtn:%d",selectedArray.count);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.Table_FileList reloadData];
    });
}

-(void) DoneBtn
{
    [self presentViewController:OptionAlert animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Popup AlertView

-(void) PopupAlertViewConfig
{
    MoveBtn = [UIAlertAction actionWithTitle:[Language get:@"OTG_Move" alter:@"Move"]
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
               {
                   Action = FileMove;
                   
                   [self UpdateDeviceStatus];
                   
                   [CloudBtn setEnabled:OTG_Plugin];
                   
                   [PhotoBtn setEnabled:(Internet && Cloud)];
                   
                   [self presentViewController:TargetAlert animated:YES completion:nil];
               }];
    
    CopyBtn = [UIAlertAction actionWithTitle:[Language get:@"OTG_Copy" alter:@"Copy"]
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
               {
                   Action = FileCopy;
                   
                   [self UpdateDeviceStatus];
                   
                   [CloudBtn setEnabled:OTG_Plugin];
                   
                   [PhotoBtn setEnabled:(Internet && Cloud)];
                   
                   [self presentViewController:TargetAlert animated:YES completion:nil];
               }];
    
    CloudBtn =  [UIAlertAction actionWithTitle:[Language get:@"OTG_Option_Move_msg4" alter:@"Cloud"]
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
               {
                   Target = CloudService;
                   
                   [self performSegueWithIdentifier:@"OTG_List_To_File_Browser"
                                             sender:self];
               }];
    
    PhotoBtn = [UIAlertAction actionWithTitle:[Language get:@"OTG_Option_Move_msg3" alter:@"Photo Center"]
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                {
                    Target = PhotoLibrary;
                    
                    [self performSegueWithIdentifier:@"OTG_List_To_File_Browser"
                                              sender:self];
                }];
    
    OptionCancelBtn = [UIAlertAction actionWithTitle:[Language get:@"OTG_Option_Move_msg2" alter:@"Cancel"]
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action)
                       {
                           Target = -1;
                           Action = -1;
                           
                           [self MultiSelectBtnClick:self];
                       }];
    
    TargetCancelBtn = [UIAlertAction actionWithTitle:[Language get:@"OTG_Option_Move_msg2" alter:@"Cancel"]
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action)
                       {
                           [self presentViewController:OptionAlert animated:YES completion:nil];
                       }];
    
    
    OptionAlert = [UIAlertController alertControllerWithTitle:[Language get:@"OTG_AlertView_msg2" alter:@"Action Option"]
                                                      message:@""
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    [OptionAlert addAction:MoveBtn];
    [OptionAlert addAction:CopyBtn];
    [OptionAlert addAction:OptionCancelBtn];
    
    TargetAlert = [UIAlertController alertControllerWithTitle:[Language get:@"OTG_AlertView_msg1" alter:@"Select Target"]
                                                      message:@""
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    [TargetAlert addAction:CloudBtn];
    [TargetAlert addAction:PhotoBtn];
    [TargetAlert addAction:TargetCancelBtn];
}

-(void) UpdateDeviceStatus
{
    nsaProtocolString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    nsmaAccessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    OTG_Plugin  = ([nsmaAccessoryList count] != 0      ? (true) : (false));
    Internet    = ([Common CheckInternet]              ? (true) : (false));
    Cloud       = ([[DBSession sharedSession] isLinked]? (true) : (false));
}

#pragma mark - UI Controller Delegate
//TODO: Implement function
- (IBAction)Btn_Encrypt_Click:(id)sender
{
}

- (IBAction)Btn_Move_Click:(id)sender
{
}

- (IBAction)Btn_Copy_Click:(id)sender
{
}

- (IBAction)Btn_Delete_Click:(id)sender
{
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // [NSThread sleepForTimeInterval:5.0f];
    
    ExternalFileInfoViewController *externalFileViewController =
        (ExternalFileInfoViewController*)[segue destinationViewController];
    
    FileBrowserIntegrateTableViewController *TargetViewController =
        (FileBrowserIntegrateTableViewController*)[segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"OTGList2Detail"])
    {
        externalFileViewController.CurrentFile = (File*)FullList[SelectIndex];
        externalFileViewController.OTGFile = OTGFile;
    }
    else if ([[segue identifier] isEqualToString:@"OTG_List_To_File_Browser"])
    {
        TargetViewController.Target = Target;
        TargetViewController.Action = Action;
    }
}

#pragma mark - UIViewController Delegate
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Loading Func

- (void)setLoading:(Boolean)Loading
{
    [self.LoadingMask setHidden:!Loading];
    
    Loading ? ([self.LoadingIndicator startAnimating]) : ([self.LoadingIndicator stopAnimating]);
}

- (IBAction)HomeBtnClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)UpdateData
{
    self.title = [Language get:@"OTG_Title2" alter:@"OTG"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"OTG_Title2" alter:@"OTG"];
    
    
    
}
@end
