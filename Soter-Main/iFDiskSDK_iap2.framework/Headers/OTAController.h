//
//  OTAController.h
//  iFDiskSDK
//
//  Created by CECAPRD on 2014/5/8.
//  Copyright (c) 2014年 CECAPRD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "EADSessionController.h"

#define TYPE_OTA_TOOL     @"OTA Tool"
#define TYPE_FW_APP       @"Firmware Application"

enum{
    OTA_BIN_UPDATE_SUCCESS = 0,
    OTA_BIN_FILE_ERROR,
    OTA_DEVICE_VERSION_IS_LATEST,
    OTA_BIN_FILE_IS_OLDER,
    OTA_BIN_FILE_VERSION_NOT_SUPPORT,
    OTA_BIN_FILE_IS_NOT_FW_CODE,
    OTA_BIN_FILE_IS_NOT_TOOL_CODE,
    OTA_ISP_CHECK_TOOL_FAIL,
    OTA_ISP_WRITE_TOOL_FAIL,
    OTA_ISP_CHECK_FW_FAIL,
    OTA_ISP_WRITE_FW_FAIL,
    OTA_ISP_ERASE_TOOL_FAIL,
    OTA_ISP_ERASE_FW_FAIL,
    OTA_ACCESSORY_REMOVED,
    OTA_JUMP_TOOL_FAIL,
    OTA_JUMP_FW_FAIL,
};

@interface OTAController : NSObject

//Init or share the OTAController
+ (OTAController *)sharedController;

//Update the iFDisk firmware (Need specifies the ID of firmware)
-(void)updateFirmware:(NSData *)data ID:(uint8_t)IDNumber isForced:(BOOL)isForced completionBlock:(void (^)(void))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

//Update the iFDisk OTA tool (Need specifies the ID of OTA tool)
-(void)updateOTATool:(NSData *)data ID:(uint8_t)IDNumber isForced:(BOOL)isForced completionBlock:(void (^)(void))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

//Update the iFDisk firmware (Need specifies the ID of firmware)
-(uint8_t)updateFirmware:(NSData *)data ID:(uint8_t)IDNumber;

//Update the iFDisk OTA tool (Need specifies the ID of OTA tool)
-(uint8_t)updateOTATool:(NSData *)data ID:(uint8_t)IDNumber;

// Return Firmware Type:
//TYPE_OTA_TOOL     @"OTA Tool"
//TYPE_FW_APP       @"Firmware Application"
- (NSString *)getFirmwareType;
@end
