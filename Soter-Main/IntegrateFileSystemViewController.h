//
//  IntegrateFileSystemViewController.h
//  Soter-Main
//
//  Created by Neil on 2015/9/1.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface IntegrateFileSystemViewController : UIViewController


/* 
 *  @brief ViewController Datasource
 *  @discussion Test
 */
@property (nonatomic) int InputType;

@property (nonatomic) NSString *Source;


/*!
 *  @brief Check if external storage exist
 */
- (Boolean) CheckExternalStorage;

/*!
 *  @brief Check if cloud service is login
 */
- (Boolean) CheckCloudAuthentication;

/*!
 *  @brief Get folder list from FileSystemAPI
 */
- (NSMutableArray *) ExternalStorageFolderList;

/*!
 *  @brief Get folder list from Dropbox API
 */
- (NSMutableArray *) CloudServiceFolderList;


-(int) ContainSubdirectory;



@end
