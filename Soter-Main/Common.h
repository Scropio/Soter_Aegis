//
//  Common.h
//  Soter-Main
//
//  Created by Neil on 2015/8/26.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "FileSystemAPI.h"
#import <DropboxSDK/DropboxSDK.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define ExternalStorage 0
#define CloudService    1
#define PhotoLibrary    2

#define FileMove    0
#define FileCopy    1

#define Move_To_OTG     0
#define Copy_To_OTG     1
#define Move_To_Cloud   2
#define Copy_To_Cloud   3
#define Move_To_Photo   4
#define Copy_To_Photo   5

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define RGB(R,G,B,Alpha) [UIColor colorWithRed:((R)/255.0) green:((G)/255.0) blue:((B)/255.0) alpha:(Alpha)]
//
//#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
//#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
//#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
//#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
//
//#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
//#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
//#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface Common : NSObject

@property (strong) NSMutableDictionary *ErrorMap;

+(void) AddFileToDevice:(NSData*)resource;

/*!
 @brief  Copy photo file to local device storage
 @param  path local file in device storage
 @author Nelson
 @date   2015/08/27
 */
+(void) CopyPhotoFromFile:(NSString*)path;

/*!
 */
+(NSString*) SaveNSDataToStorage:(NSString *)Filename Image:(UIImage *)image;

//@property (nonatomic) NSArray *ServiceList;

+(NSString *) ServiceMapping:(NSString *)ServiceName;

+(Boolean) CheckInternet;

+(NSData *) ConvertALAssetToNSData : (ALAsset *)PhotoAsset;

+(NSString *) SaveNSDataToLocalAppFolder : (NSString *)FileName RawData:(NSData *) RawData;

+(Boolean) isValidPhoto : (NSString*) FileName;

-(NSDictionary *) UpdateDeviceStatus;

@end
