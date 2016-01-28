//
//  GlobalInfo.m
//  Soter-Main
//
//  Created by Neil on 2015/6/18.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "GlobalInfo.h"

@implementation GlobalInfo

@synthesize SuperPassword;

+ (id)ShareGlobalInfo
{
    static GlobalInfo *_GlobalInfo = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _GlobalInfo = [[self alloc]init];
    });
    
    return _GlobalInfo;
}

- (id)init
{
    if ( self = [super init])
    {
        SuperPassword = @"";
        
        self.SCREEN_HEIGHT  = [[UIScreen mainScreen] bounds].size.height;
        self.SCREEN_WIDTH   = [[UIScreen mainScreen] bounds].size.width;
    }
    return self;
}

@end
