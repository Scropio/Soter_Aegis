//
//  PhotoCenter_Album_TableViewController.m
//  Soter
//
//  Created by Neil on 2015/4/23.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "PhotoCenter_Album_TableViewController.h"
#import "PhotoCenter_Photo_CollectionViewController.h"
#import "PhotoCenter_Photo_Layout.h"
#import "Language.h"
#import "LanguageViewController.h"


@interface PhotoCenter_Album_TableViewController ()
{
    ALAssetsGroup   *SeguePhotoAsset;
    NSString        *SegueAlbumName;
    NSMutableArray  *galleryImages;
    
    float ViewCellSize;
}
@end

static NSString *CellIdentifier = @"PhotoCellIdentifier";

@implementation PhotoCenter_Album_TableViewController

@synthesize photoGroup,HomeBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set background
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"Curtain"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

    //Set ViewCellSize
    ViewCellSize = self.tableView.frame.size.height / 6;
    
    //Set HomeBtn on navigation bar
    [HomeBtn setImage:[[UIImage imageNamed:@"home.png"]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

- (void)viewDidAppear:(BOOL)animated
{

   
    [self fetchGalleryListings];
        [self UpdateData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    ALAssetsGroup *g = (ALAssetsGroup*)[_galleryImages objectAtIndex:indexPath.row];
//    CWPhotoViewerGridFlowLayout *layout = [[CWPhotoViewerGridFlowLayout alloc] init];
    
//    PhotoCenter_Photo_Layout *layout = [[PhotoCenter_Photo_Layout alloc] init];
//    
    ALAssetsGroup *current = (ALAssetsGroup*)[galleryImages objectAtIndex:indexPath.row];
    
    SeguePhotoAsset = (ALAssetsGroup*)[galleryImages objectAtIndex:indexPath.row];
    SegueAlbumName = [current valueForProperty:ALAssetsGroupPropertyName];
    
//    photo.photoGroup = current;
//    photo.galleryTitle = [current valueForProperty:ALAssetsGroupPropertyName];
    
    [self performSegueWithIdentifier:@"Album2Photo2" sender:self];
    
//    [self.navigationController pushViewController:photo animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PhotoCenter_Photo_CollectionViewController *Photo_Collect_View = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"Album2Photo2"])
    {
        Photo_Collect_View.photoGroup = SeguePhotoAsset;
        Photo_Collect_View.galleryTitle = SegueAlbumName;
    }
}




// This will tell your UITableView what data to put in which cells in your table.
#pragma mark - UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(Cell == nil)
    {
        Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        Cell.tag = indexPath.row;
    }
    
    Cell.backgroundColor = [UIColor clearColor];
    
    ALAssetsGroup *current = (ALAssetsGroup*)[galleryImages objectAtIndex:indexPath.row];
    [current setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger photoCount = [current numberOfAssets];
    
    //Thumbnail
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, ViewCellSize , ViewCellSize)];
    
    [imgView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)[galleryImages objectAtIndex:indexPath.row] posterImage]]];

    
    //Title
    UILabel *Title = [[UILabel alloc]initWithFrame:CGRectMake(ViewCellSize + 20, ViewCellSize / 2, 50, 30)];
    Title.text = [NSString stringWithFormat:@"%@", [current valueForProperty:ALAssetsGroupPropertyName]];
    Title.font = [UIFont systemFontOfSize:20];
    [Title sizeToFit];
    
    UILabel *Count = [[UILabel alloc]initWithFrame:CGRectMake(Title.frame.origin.x + Title.frame.size.width + 5, ViewCellSize / 2, 50, 30)];
    Count.text = [NSString stringWithFormat:@"(%ld)",(long)photoCount];
    Count.textColor = [UIColor grayColor];
    [Count sizeToFit];

    [Cell addSubview:imgView];
    [Cell addSubview:Title];
    [Cell addSubview:Count];
    
    return Cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ViewCellSize + 20;
}

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [galleryImages count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return UITableViewCellEditingStyleDelete;
}


#pragma mark - Public Methods

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    
    static dispatch_once_t pred     = 0;
    static ALAssetsLibrary *library = nil;
    
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    
    return library;
}

- (void)fetchGalleryListings {
    
    galleryImages = [[NSMutableArray alloc] init];
    
    ALAssetsLibrary *library = [PhotoCenter_Album_TableViewController defaultAssetsLibrary];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^{
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum|ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (group) {
                
                if ([group valueForProperty:ALAssetsGroupPropertyName]) {
                    
                    if (!galleryImages) {
                        
                        galleryImages = [[NSMutableArray alloc] init];
                    }
                    
                    NSLog(@"album: %@", [group valueForProperty:ALAssetsGroupPropertyName]);
                    
                    [galleryImages addObject:group];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[self Table_AlbumList] reloadData];
                    });
                }
            }
            
        } failureBlock:^(NSError *error) {
            
            NSLog(@"error loading assets: %@", [error localizedDescription]);
        }];
    });
}
- (IBAction)HomeBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark update data
-(void)UpdateData
{
    self.title = [Language get:@"PhotoCenter_Title" alter:@"Photo Album"];
    self.navigationController.navigationBar.backItem.title = [Language get:@"PhotoCenter_Title" alter:@"Photo Album"];
    
    
    
}


@end
