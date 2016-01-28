//
//  iFDiskSDK_iAP2.h
//  iFDiskSDK
//
//  Created by CECAPRD on 2014/1/10.
//  Copyright (c) 2014年 CECAPRD. All rights reserved.
//
//SDK Version : 0.39

#import <Foundation/Foundation.h>

#import "EADSessionController.h"
#import "FileSystemController.h"
#import "OTAController.h"
#import "BatteryDetection.h"
#import "streamURLSession.h"

@interface iFDiskSDK_iap2 : NSObject

// Return the iFDisk SDK version
+ (NSString *)getSDKVersion;

@end
