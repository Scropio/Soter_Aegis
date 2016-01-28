//
//  GlobalInfo.h
//  Soter-Main
//
//  Created by Neil on 2015/6/18.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileSystemAPI.h"



@interface GlobalInfo : NSObject

@property (nonatomic, retain) NSString *SuperPassword;

@property (nonatomic) float SCREEN_WIDTH;
@property (nonatomic) float SCREEN_HEIGHT;

@property (nonatomic, retain) FileSystemAPI *fsaAPI;

+ (id)ShareGlobalInfo;

//- (NSString *) getSuperPassword;
//- (NSString *) setSuperPassword;

@end
