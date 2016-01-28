//
//  CloudFileListTableViewController.m
//  Soter-Main
//
//  Created by Neil on 2015/5/20.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "CloudFileListTableViewController.h"
#import "File.h"
#import "RDActionSheet.h"
#import "FileType.h"

#import "CloudDetailViewController.h"

@interface CloudFileListTableViewController () <DBRestClientDelegate>
{
    NSMutableArray *PathList;
    NSMutableArray *FileList;
    DBRestClient *restClient;
    
    FileType *FileThumbnail;
    
    NSInteger SelectIndex;
}
@end

@implementation CloudFileListTableViewController

static NSString *Identifier;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FileList = [[NSMutableArray alloc] init];
    PathList = [[NSMutableArray alloc] init];
    
    restClient = [[DBRestClient alloc] initWithSession: [DBSession sharedSession]];
    restClient.delegate = self;
    
    if (![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"Dropbox Re-linked");
    }
    else
    {
        NSLog(@"Dropbox is Linked");
    }
    [PathList addObject:@"/"];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Curtain"]];
    
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
    
    
    
//    [restClient loadMetadata:@"/"];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor redColor]];
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [restClient loadMetadata:@"/"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return FileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"TCell" forIndexPath:indexPath];
    
//    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];//以indexPath来唯一确定cell
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)indexPath.section, (long)indexPath.row];
    
    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(Cell == nil)
    {
        Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    UILabel *FileName = [[UILabel alloc]initWithFrame:CGRectMake(84, 22, 250, 40)];
    
    File *cFile = FileList[indexPath.row];
    
    if (cFile.FileExtension != NULL)
    {
        FileName.text = [[NSString alloc] initWithFormat:@"%@.%@" ,cFile.FileName ,cFile.FileExtension];
    }
    else
    {
        FileName.text = [[NSString alloc] initWithFormat:@"%@" ,cFile.FileName];
    }
    UIImageView *Type = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 64, 64)];
    
    
    if (cFile.FileType == eFOLDER)
    {
        [Type setImage:[UIImage imageNamed:@"Folder_icon"]];
    }
    else
    {
        UIImage *Thumbnail = [FileType getThumbnail  :cFile.FileExtension ImageSize:YES];
        
        [Type setImage: Thumbnail];
    }
    
    [Cell addSubview:Type];
    [Cell addSubview:FileName];
//    }
    
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
        //        [arrYears removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

//Dropbox API Start
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
            [cFilePath appendString: PathList[i]];
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
                cFile.FileExtension = FileSpilt[1];
                cFile.FileExtension = cFile.FileExtension.lowercaseString;
                cFile.FileType = (CATEGORY*)eFILE;
                
                cFile.FilePath = [self CombinationFullPath:file.filename];
                
                NSLog(@"cFile.FilePath=%@",cFile.FilePath);
            }
            
            [FileList addObject:cFile];
        }
        
        if(![[NSThread currentThread] isMainThread])
        {
            [self performSelector:@selector(reloadData) onThread:[NSThread mainThread] withObject:self.tableView waitUntilDone:NO];
        }
        [self.tableView reloadData];
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

- (IBAction)Detail_Action:(id)sender
{
    RDActionSheet *actionSheet = [[RDActionSheet alloc]
                                  initWithTitle:@"Select target to upload"
                                  cancelButtonTitle:@"Cancel"
                                  primaryButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Upload to OTG",nil];
    
    
    NSLog(@"Block callbacks enabled");
    actionSheet.callbackBlock = ^(RDActionSheetCallbackType type, NSInteger buttonIndex, NSString *buttonTitle) {
        switch (type) {
            case RDActionSheetCallbackTypeClickedButtonAtIndex:
                NSLog(@"RDActionSheetCallbackTypeClickedButtonAtIndex %ld, title %@", buttonIndex, buttonTitle);
                break;
            case RDActionSheetCallbackTypeDidDismissWithButtonIndex:
                NSLog(@"RDActionSheetCallbackTypeDidDismissWithButtonIndex %ld, title %@", buttonIndex, buttonTitle);
                break;
            case RDActionSheetCallbackTypeWillDismissWithButtonIndex:
                NSLog(@"RDActionSheetCallbackTypeWillDismissWithButtonIndex %ld, title %@", buttonIndex, buttonTitle);
                break;
            case RDActionSheetCallbackTypeDidPresentActionSheet:
                NSLog(@"RDActionSheetCallbackTypeDidPresentActionSheet");
                break;
            case RDActionSheetCallbackTypeWillPresentActionSheet:
                NSLog(@"RDActionSheetCallbackTypeDidPresentActionSheet");
                break;
        }
    };
    [actionSheet showFrom:self.view];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(NSString *) CombinationFullPath : (NSString*) FileName
{
    NSMutableString *_FilePath = [[NSMutableString alloc] init];
    
    for (int i = 0 ; i < PathList.count ; i++)
    {
        [_FilePath appendString:PathList[i]];
    }
    
    [_FilePath appendString:@"/"];
    
    [_FilePath appendString:FileName];
    
    NSLog(@"PathList.count:%ld",(long)PathList.count);
    NSLog(@"FilePath:%@",_FilePath);
    
    return _FilePath;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CloudDetailViewController *Cloud_Detail_View = (CloudDetailViewController *) [segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"CloudList2FileDetail"])
    {
        Cloud_Detail_View.CurrentFile = (File *)FileList[SelectIndex];
    }
}


@end
