//
//  pListController.h
//  Soter-Main
//
//  Created by Neil on 2015/6/18.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pListController : NSObject

//@property (nonatomic, retain) NSString *SuperPassword;
//@property (nonatomic, strong) id filePathObj;

- (void)readPlist;

- (NSString *)getProperty:(NSString *)Key;
- (Boolean)updateProperty:(NSString *)_Key Value:(NSString *)_Value;

//-(void)CreateAppPlist;
//
//-(void)ReadAppPlist;
//
//-(void)CreateCFPlist;
//
//-(void)ReadCFPlist;

@end
