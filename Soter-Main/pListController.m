//
//  pListController.m
//  Soter-Main
//
//  Created by Neil on 2015/6/18.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "pListController.h"

@implementation pListController
{
    NSMutableDictionary *plistDict;
    NSString *plistPath;
}

NSString *const PROPERTY_FILENAME = @"soter";
//NSString *const PROPERTY_FILENAME = @"Info";

- (id)init
{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent: [PROPERTY_FILENAME stringByAppendingFormat:@".plist"] ];
    
//    plistPath = [[NSBundle mainBundle] pathForResource:PROPERTY_FILENAME ofType:@"plist"];
//    plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: plistPath]) //檢查檔案是否存在
    {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    }else{
        plistDict = [[NSMutableDictionary alloc] init];
        
        [self updateProperty:@"SuperPassword" Value:@"1234"];
        
        NSLog(@"plist File do not exist:%@",plistPath);
    }
    
    return self;
}

- (NSString *)getProperty:(NSString *)Key
{
    NSString *value = @"";
//    NSLog(@"plistPath:%@",plistPath);
    value = [plistDict objectForKey:Key];
    return value;
}

- (Boolean)updateProperty:(NSString *)_Key Value:(NSString *)_Value
{
    //取得檔案路徑
    NSString *error;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[PROPERTY_FILENAME stringByAppendingFormat:@".plist"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: filePath]) //檢查檔案是否存在
    {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    }else{
        plistDict = [[NSMutableDictionary alloc] init];
    }
    
    [plistDict setValue:_Value forKey:_Key];
    
    if ([plistDict writeToFile:filePath atomically:YES])
    {
        NSLog(@"Write pList Success");
    }
    else
    {
        NSLog(@"Write pList Error");
    }
    
    return false;
}



@end
