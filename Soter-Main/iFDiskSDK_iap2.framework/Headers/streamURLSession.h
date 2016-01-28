//
//  streamURLSession.h
//  iFDiskSDK
//
//  Created by CECAPRD on 2014/1/14.
//  Copyright (c) 2014年 CECAPRD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface streamURLSession : NSObject

// Gets the stream URL of the file.
- (NSString *)start:(NSString *)fileName;

// Close the session.
- (void)stop;

@end
