//
//  Database.h
//  DBHelper
//
//  Created by Neil on 2015/5/13.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "Account.h"

@interface Database : NSObject

- (BOOL)open;

- (void)close;

- (void)initialized;

- (void)insertData:(NSString *)_Name Username:(NSString *)_Username Password:(NSString *)_Password Comment:(NSString *)_Comment;

- (void)updataData:(NSString *)_ID
       ServiceName:(NSString *)_ServiceName
          Username:(NSString *)_Username
          Password:(NSString *)_Password
           Comment:(NSString *)_Comment;

- (NSArray*)selectData;

- (NSArray*)selectData:(NSString *)_Table Name:(NSString *)_Name;

- (void)deleteData;

- (void)deleteData:(NSString *)SQL;

@end
