//
//  File.h
//  Soter-Main
//
//  Created by Neil on 2015/6/22.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ROOT_PATH       @"/"
#define PRE_FOLDER      @"..."

typedef enum
{
    eFOLDER = 0,
    eFILE   = 1
}CATEGORY;

typedef enum
{
    eTXT = 0,
    ePDF,
    eDOC,
    eXLS,
    ePPT,
    ePNG,
    eGIF,
    eJPG,
    eBMP
}FILE_TYPE;

@interface File : NSObject

@property (nonatomic, strong)   NSString    *FileName;
@property (nonatomic, strong)   NSString    *FullFileName;
@property (nonatomic, strong)   NSString    *FileExtension;
@property (nonatomic)           int         FileSize;
@property (nonatomic, assign)   CATEGORY    *FileType;
@property (nonatomic, strong)   NSString    *FilePath;
@property (nonatomic, strong)   NSString    *FileDate;

-(id) initWithFilePath: (NSString *)cFilePath;
-(id) initWithFilePath: (NSString *)cFilePath FirstDate: (NSString*) FileDate;

-(UIImage*) getThumbnail;

@end
