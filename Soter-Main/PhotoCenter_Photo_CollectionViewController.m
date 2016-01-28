//
//  PhotoCenter_Photo_CollectionViewController.m
//  Soter
//
//  Created by Neil on 2015/4/23.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "PhotoCenter_Photo_CollectionViewController.h"
#import "PhotoCenter_Preview_ViewController.h"
#import "PhotoCenter_Photo_Layout.h"
#import "Language.h"
#import "LanguageViewController.h"


@interface PhotoCenter_Photo_CollectionViewController ()
{
    NSMutableArray *galleryImages;
    
    NSString    *SelectedPhotoName;
    UIImage     *SegueImage;
    ALAsset     *SelectedAlAsset;
    
    FileSystemAPI *fsaAPI;
    EADSessionController *escSessionController;
    OTAController *OTAISP;
    
    float CellSize;
    float Spacing;
    
    NSMutableArray *selectedArray;
    NSMutableArray *SelectAssestArray;
    
    BOOL MultiMode;
    
    UIBarButtonItem *MultiSelect;
    
    UIBarButtonItem *SelectBtn;
    UIBarButtonItem *DeSelectBtn;
    UIBarButtonItem *DoneBtn;
    UIBarButtonItem *CancelBtn;
    
    bool BottomMenuShowed;
    
    bool OTG_Plugin;
    bool Internet;
    bool Cloud;
    
    DBRestClient *restClient;
    
    NSMutableArray *nsmaAccessoryList;
    NSArray *nsaProtocolString;
    
    UIAlertController *OptionAlert;
    UIAlertController *TargetAlert;
    
        UIAlertAction *MoveBtn;
        UIAlertAction *CopyBtn;
        UIAlertAction *OTGBtn;
        UIAlertAction *CloudBtn;
        UIAlertAction *OptionCancelBtn;
        UIAlertAction *TargetCancelBtn;
    
    int Action;
    int Target;
    
    
}
@end

@implementation PhotoCenter_Photo_CollectionViewController

@synthesize Collect_Photo;
@synthesize BottomBarMenu;

static NSString * const reuseIdentifier = @"PhotoCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MultiMode = false;
    
    selectedArray = [[NSMutableArray alloc] init];
    SelectAssestArray = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    NSLog(@"%@",self.galleryTitle);
    
    self.navigationItem.title = self.galleryTitle;
    
    // Register cell classes
    [Collect_Photo registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [Collect_Photo setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 0, 0)];
    
    //Set view background
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    [Collect_Photo setBackgroundColor:[UIColor clearColor]];
    
    UIScreen *screen = [UIScreen mainScreen];
//    CGRect fullRect = screen.bounds;
    
    if(IS_IPAD)
    {
        //Calculate cell
        CellSize = Collect_Photo.frame.size.width/6;
        Spacing = (Collect_Photo.frame.size.width - CellSize * 5) / 10;
    }
    
    if(IS_IPHONE)
    {
        //Calculate cell
        CellSize = Collect_Photo.frame.size.width/4;
        Spacing = (Collect_Photo.frame.size.width - CellSize * 3) / 6;
    }
    
    BottomMenuShowed = false;
    self.BottomBarMenu.backgroundColor = RGB(40.0, 114.0, 195.0, 0.8);
    self.BottomBarMenu.frame = CGRectMake(self.BottomBarMenu.frame.origin.x,
                                          self.view.bounds.size.height,
                                          self.BottomBarMenu.frame.size.width,
                                          self.BottomBarMenu.frame.size.height);

    //Set collectionview flowlayout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(CellSize, CellSize)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, Spacing, Spacing, Spacing)];
    
    [self.Collect_Photo setCollectionViewLayout:flowLayout];
    
    //Regist custom cell
    UINib *cellNib = [UINib nibWithNibName:@"PhotoCellView" bundle:nil];
    [Collect_Photo registerNib:cellNib forCellWithReuseIdentifier:reuseIdentifier];
    
    //Add MultiSelect button on rightBarButtonItems
//    UIBarButtonItem *MultiSelect = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MultiSelect"]
//                                                                    style:UIBarButtonItemStyleDone
//                                                                   target:self
//                                                                   action:@selector(MultiSelectSwitch:) ];
    
    MultiSelect = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MultiSelect"]
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(MultiSelectSwitch)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:MultiSelect,nil];
    
    [self PopupAlertViewConfig];
}

- (void)viewWillAppear:(BOOL)animated
{
   // [self UpdateData];

    //Ray for Ver.1.0.1
    //start
    //===========================================================================================
    //Create NotificationCenter to receive the external accessory state information
    //    //註冊插入事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDidConnectPhoto:)
                                                 name:EAAccessoryDidConnectNotification
                                               object:nil];
    //    //註冊移除事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDidDisconnectPhoto:)
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
        [self accessoryDidAlreadyConnectPhoto];
    }
    //end
}

- (void)viewDidDisappear:(BOOL)animated
{
    fsaAPI = nil;
    OTAISP = nil;
    
    //unregister connect
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    //unregister disconnect
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
    
    MultiMode = true;
    [self MultiSelectSwitch];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self fetchGalleryImages];
    
//    MultiMode = false;
//    [self MultiSelectSwitch];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    CGSize retval = CGSizeMake(84, 84);
    CGSize retval = CGSizeMake(CellSize, CellSize);
    
    return retval;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.photoGroup numberOfAssets];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

int a = 0;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Total:%d", [self.photoGroup numberOfAssets]);
    
//    PhotoCollectionViewCell *cell = [Collect_Photo dequeueReusableCellWithReuseIdentifier:reuseIdentifier
//                                                                             forIndexPath:indexPath];
    
//    ALAsset *asset     = (ALAsset *)galleryImages[indexPath.row];
//    UIImage *thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
    
//    NSLog(@"%d %d",indexPath.section,indexPath.row);
    
//    [cell.Checkmark setHidden:MultiMode];
//    [cell.PhotoImage setImage:thumbnail];
//    
//    if([selectedArray containsObject:indexPath])
//    {
//        [cell.Checkmark setImage:[UIImage imageNamed:@"Checkmark.png"]];
//    }
//    else
//    {
//        [cell.Checkmark setImage:[UIImage imageNamed:@"UnCheckmark.png"]];
//    }
//    
//    return nil;
    
//    UICollectionViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PhotoCollectionViewCell *Cell = [Collect_Photo dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    ALAsset *asset     = (ALAsset *)galleryImages[indexPath.row];
    UIImage *thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
    
    [Cell.Checkmark setHidden:!MultiMode];
    [Cell.PhotoImage setImage:thumbnail];

    if([selectedArray containsObject:indexPath])
    {
        [Cell.Checkmark setImage:[UIImage imageNamed:@"Checkmark"]];
    }
    else
    {
        [Cell.Checkmark setImage:[UIImage imageNamed:@"UnCheckmark"]];
    }
    
//    UIImageView *ThumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CellSize , CellSize)];
//    [ThumbnailView setImage:thumbnail];

//    ThumbnailView.backgroundColor = [UIColor clearColor];
    
//    [Cell addSubview:ThumbnailView];
    return Cell;
}

#pragma mark - OTG Delegate


#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = (ALAsset *)galleryImages[indexPath.row];
    
    if (!MultiMode)
    {
        UIImageView *Oringinal = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];
        
        ALAssetRepresentation *AssetRepresent = [asset defaultRepresentation];
        
        UIImage *Photo = [UIImage imageWithCGImage:[[asset defaultRepresentation]fullScreenImage]];
        
        Oringinal.image = Photo;
        
        SelectedPhotoName = [AssetRepresent filename];
        
        NSLog(@"PhotoName:%@",SelectedPhotoName);
        
        SegueImage = Photo;
        
        SelectedAlAsset = asset;
        
        [self performSegueWithIdentifier:@"PhotoCollection2Preview2"
                                  sender:self];
    }
    else
    {
        if([selectedArray containsObject:indexPath])
        {
            [self CheckmarkStatus:indexPath Status:false RefreshCell:true];
            
            [SelectAssestArray removeObject:asset];
        }
        else
        {
            [self CheckmarkStatus:indexPath Status:true RefreshCell:true];
            
            [SelectAssestArray addObject:asset];
        }
    }
}

-(void) CheckmarkStatus:(NSIndexPath *)indexPath Status:(BOOL) status RefreshCell:(BOOL) refresh
{
    PhotoCollectionViewCell *cell = [Collect_Photo dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                             forIndexPath:indexPath];
    
    if(status)
    {
        [cell.Checkmark setImage:[UIImage imageNamed:@"Checkmark.png"]];
        
        if(![selectedArray containsObject:indexPath])
        {
            [selectedArray addObject:indexPath];
            
            
        }
    }
    else
    {
        [cell.Checkmark setImage:[UIImage imageNamed:@"UnCheckmark.png"]];
        
        [selectedArray removeObject:indexPath];
    }
    
    if(refresh)
    {
        [Collect_Photo reloadItemsAtIndexPaths:@[indexPath]];
    }
}

#pragma mark - Private Methods

- (void)fetchGalleryImages
{
    
    NSLog(@"FetchGalleryImages");
    
    dispatch_async(dispatch_get_main_queue(), ^{

        galleryImages = [NSMutableArray new];
    
        [self.photoGroup enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
        {
            if (asset)
            {
                [galleryImages addObject:asset];
                
                NSLog(@"%ld",(long)index);
            }
        }];
        
        [Collect_Photo reloadData];
    });
}

-(void) MultiSelectSwitch
{
    NSLog(@"MultiSelect:%d",MultiMode);
    
    MultiMode = !MultiMode;
    
    if(MultiMode)
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
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:MultiSelect,nil];
        
        self.navigationItem.leftBarButtonItems = nil;
        
        [self.navigationItem setHidesBackButton:NO];
    }
    
    for (PhotoCollectionViewCell *cell in [self.Collect_Photo visibleCells])
    {
        NSIndexPath *indexPath = [self.Collect_Photo indexPathForCell:cell];
        
        [Collect_Photo reloadItemsAtIndexPaths:@[indexPath]];
    }
}

-(void) CancelBtn
{
    MultiMode = true;
    [self MultiSelectSwitch];
}

-(void) DeselectAllBtn
{
    NSIndexPath *current;
    
    NSLog(@"SelectedArray : %d ", selectedArray.count);
    
    for (int i = selectedArray.count -1 ; i >= 0 ; i--)
    {
        current = selectedArray[i];
        
        [self CheckmarkStatus:current Status:false RefreshCell:false];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [Collect_Photo reloadData];
    });
}

-(void) SelectAllBtn
{
    NSIndexPath *current;
    
    for (NSInteger section = 0 ; section < [self.Collect_Photo numberOfSections] ; section++)
    {
        for (NSInteger row = 0; row < [self.Collect_Photo numberOfItemsInSection:0]; row++)
        {
            current = [NSIndexPath indexPathForRow:row
                                         inSection:section];
            
            NSLog(@"%d %d", current.section, current.row);
            
            if(![selectedArray containsObject:current])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self CheckmarkStatus:current Status:true RefreshCell:false];
                });
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [Collect_Photo reloadData];
    });
}

-(void) DoneBtn
{
    [self presentViewController:OptionAlert animated:YES completion:nil];
}

-(void) BottomMenuAnimateControl
{
    BottomMenuShowed = !BottomMenuShowed;
    
    if(!BottomMenuShowed)
    {
        [UIView animateWithDuration:0.6 animations:^{
            
            self.BottomBarMenu.frame = CGRectMake(self.BottomBarMenu.frame.origin.x,
                                                  self.view.frame.size.height,
                                                  self.BottomBarMenu.frame.size.width,
                                                  self.BottomBarMenu.frame.size.height);
        }];
        
        //        [actionSheet showFrom:self.view];UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(XPosition, YPosition, Width, Height)];
    }
    else
    {
        [UIView animateWithDuration:0.6 animations:^{
            
            self.BottomBarMenu.frame = CGRectMake(self.BottomBarMenu.frame.origin.x,
                                                  self.view.frame.size.height - self.BottomBarMenu.frame.size.height,
                                                  self.BottomBarMenu.frame.size.width,
                                                  self.BottomBarMenu.frame.size.height);
        }];
    }
}
- (IBAction)MoveBtn:(id)sender
{
    RDActionSheet *actionSheet = [self RDActionOptionProcessor:[Language get:@"PhotoCenter_Option_Move_msg1" alter:@"Select move to target"]
                                                  CancelButton:[Language get:@"PhotoCenter_Cancel" alter:@"Cancel"]];
    
    NSLog(@"Block callbacks enabled");
    actionSheet.callbackBlock = ^(RDActionSheetCallbackType type,
                                  NSInteger buttonIndex,
                                  NSString *buttonTitle)
    {
        if(type == RDActionSheetCallbackTypeClickedButtonAtIndex)
        {
            Action = FileMove;
            
            if([buttonTitle isEqualToString:@"OTG"])
            {
                Target = ExternalStorage;
            }
            
            if([buttonTitle isEqualToString:@"Cloud"])
            {
                Target = CloudService;
            }
        }
        [self performSegueWithIdentifier:@"Photo_List_To_File_Browser"
                                  sender:self];
    };
    
    [actionSheet showFrom:self.view];
}
- (IBAction)CopyBtn:(id)sender
{
    RDActionSheet *actionSheet = [self RDActionOptionProcessor:[Language get:@"PhotoCenter_Option_Copy_msg1" alter:@"Select copy to target"]
                                                  CancelButton:[Language get:@"PhotoCenter_Cancel" alter:@"Cancel"]];
    
    NSLog(@"Block callbacks enabled");
    actionSheet.callbackBlock = ^(RDActionSheetCallbackType type,
                                  NSInteger buttonIndex,
                                  NSString *buttonTitle)
    {
        if(type == RDActionSheetCallbackTypeClickedButtonAtIndex)
        {
            Action = FileCopy;
            
            if([buttonTitle isEqualToString:@"OTG"])
            {
                Target = ExternalStorage;
            }
            
            if([buttonTitle isEqualToString:@"Cloud"])
            {
                Target = CloudService;
            }
        }
        
        [self performSegueWithIdentifier:@"Photo_List_To_File_Browser"
                                  sender:self];
    };
    
    [actionSheet showFrom:self.view];
}
- (IBAction)DelBtn:(id)sender
{
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

#pragma mark - Popup AlertView

-(void) PopupAlertViewConfig
{
    MoveBtn = [UIAlertAction actionWithTitle:[Language get:@"PhotoCenter_error_msg3" alter:@"Move (Not support at here)"]
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                    {
                                        Action = FileMove;
                                        
                                        [self UpdateDeviceStatus];
                                        
                                        [OTGBtn setEnabled:OTG_Plugin];
                                        
                                        [CloudBtn setEnabled:(Internet && Cloud)];
                                        
                                        [self presentViewController:TargetAlert animated:YES completion:nil];
                                    }];
    
    CopyBtn = [UIAlertAction actionWithTitle:[Language get:@"PhotoCenter_Copy" alter:@"Copy"]
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                    {
                                        Action = FileCopy;
                                        
                                        [self UpdateDeviceStatus];
                                        
                                        [OTGBtn setEnabled:OTG_Plugin];
                                        
                                        [CloudBtn setEnabled:(Internet && Cloud)];
                                        
                                        [self presentViewController:TargetAlert animated:YES completion:nil];
                                    }];
    
    OTGBtn =  [UIAlertAction actionWithTitle:[Language get:@"PhotoCenter_OTG" alter:@"OTG"]
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                    {
                                        Target = ExternalStorage;
                                        
                                        [self performSegueWithIdentifier:@"Photo_List_To_File_Browser"
                                                                  sender:self];
                                    }];
    
    CloudBtn = [UIAlertAction actionWithTitle:[Language get:@"PhotoCenter_Cloud" alter:@"Cloud"]
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                        {
                                            Target = CloudService;
                                            
                                            [self performSegueWithIdentifier:@"Photo_List_To_File_Browser"
                                                                      sender:self];
                                        }];
    
    OptionCancelBtn = [UIAlertAction actionWithTitle:[Language get:@"PhotoCenter_Cancel" alter:@"Cancel"]
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action)
    {
        Target = -1;
        Action = -1;
        
        [self MultiSelectSwitch];
    }];
    
    TargetCancelBtn = [UIAlertAction actionWithTitle:[Language get:@"PhotoCenter_Cancel" alter:@"Cancel"]
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action)
    {
        [self presentViewController:OptionAlert animated:YES completion:nil];
    }];
    
    
    OptionAlert = [UIAlertController alertControllerWithTitle:[Language get:@"PhotoCenter_Option_Move_msg6" alter:@"Action Option"]
                                                      message:@""
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    [OptionAlert addAction:MoveBtn];
    [OptionAlert addAction:CopyBtn];
    [OptionAlert addAction:OptionCancelBtn];
    
    [MoveBtn setEnabled:false];
    
    TargetAlert = [UIAlertController alertControllerWithTitle:[Language get:@"PhotoCenter_Option_Move_msg5" alter:@"Select Target"]
                                                      message:@""
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    [TargetAlert addAction:OTGBtn];
    [TargetAlert addAction:CloudBtn];
    [TargetAlert addAction:TargetCancelBtn];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PhotoCollection2Preview2"])
    {
        PhotoCenter_Preview_ViewController *Photo_Preview_View = segue.destinationViewController;
        
        Photo_Preview_View.PhotoName = SelectedPhotoName;
        Photo_Preview_View.PreviewPhoto = SegueImage;
        Photo_Preview_View.PhotoAsset = SelectedAlAsset;
    }
    else if ([segue.identifier isEqualToString:@"Photo_List_To_File_Browser"])
    {
        FileBrowserIntegrateTableViewController *TargetView = segue.destinationViewController;
        
        TargetView.Source = PhotoLibrary;
        
        TargetView.TargetFiles = SelectAssestArray;
        TargetView.Action = Action;
        TargetView.Target = Target;
    }
}


#pragma mark update data
-(void)UpdateData
{
    self.title = [Language get:@"PhotoCenter_Title" alter:@"Photo Album"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"PhotoCenter_Title" alter:@"Photo Album"];
    
    
    
}



@end
