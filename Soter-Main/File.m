//
//  File.m
//  Soter-Main
//
//  Created by Neil on 2015/6/22.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "File.h"

@implementation File

@synthesize FileName;
@synthesize FullFileName;
@synthesize FileType;
@synthesize FileExtension;
@synthesize FileSize;
@synthesize FilePath;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.FileName       = [[NSString alloc] init];
        self.FullFileName    = [[NSString alloc] init];
        self.FileExtension  = [[NSString alloc] init];
        self.FileType       = FileType;
        self.FileSize       = 0;
        self.FileDate       = @"Unknow";
    }
    return self;
}

-(id) initWithFilePath: (NSString *)cFilePath
{
    self = [super init];
    
    if (self)
    {
        if([cFilePath isEqualToString:@"..."])
        {
            self.FileType = nil;
            self.FileName = @"...";
            self.FileExtension = @"";
            self.FilePath = @"";
        }
        if([cFilePath containsString:@"."])
        {
            self.FullFileName = cFilePath;
            self.FileType = (CATEGORY *)eFILE;
            self.FileName = [cFilePath lastPathComponent];
            self.FileExtension = [[self.FileName pathExtension] lowercaseString];
            self.FilePath = cFilePath;
        }
        else
        {
            self.FileType = (CATEGORY *)eFOLDER;
            self.FileName = [cFilePath lastPathComponent];
            self.FileExtension = nil;
            self.FilePath = cFilePath;
        }
    }
    
    
    return self;
}

-(id) initWithFilePath: (NSString *)cFilePath FirstDate: (NSString*) FileDate
{
    self = [super init];
    
    if (self)
    {
        if([cFilePath isEqualToString:@"..."])
        {
            self.FileType = nil;
            self.FileName = @"...";
            self.FileExtension = @"";
            self.FilePath = @"";
        }
        if([cFilePath containsString:@"."])
        {
            self.FullFileName = cFilePath;
            self.FileType = (CATEGORY *)eFILE;
            self.FileName = [cFilePath lastPathComponent];
            self.FileExtension = [[self.FileName pathExtension] lowercaseString];
            self.FilePath = cFilePath;
            self.FileDate = FileDate;
        }
        else
        {
            self.FileType = (CATEGORY *)eFOLDER;
            self.FileName = [cFilePath lastPathComponent];
            self.FileExtension = nil;
            self.FilePath = cFilePath;
            self.FileDate = FileDate;
        }
    }
    
    
    return self;
}

- (UIImage*) getThumbnail
{
    if (self.FileType == eFOLDER)  return [UIImage imageNamed:@"Folder_icon"];
    
    if ([self.FileExtension isEqualToString:@"pdf"])   return [UIImage imageNamed:@"PDF"];
    if ([self.FileExtension isEqualToString:@"gif"])   return [UIImage imageNamed:@"Menu06_gif"];
    if ([self.FileExtension isEqualToString:@"txt"])   return [UIImage imageNamed:@"Text_File"];
    if ([self.FileExtension isEqualToString:@"docx"])  return [UIImage imageNamed:@"Menu06_microsoft docx"];
    if ([self.FileExtension isEqualToString:@"xlsx"])  return [UIImage imageNamed:@"Menu06_microsoft xlsx"];
    if ([self.FileExtension isEqualToString:@"png"])   return [UIImage imageNamed:@"PNG"];
    if ([self.FileExtension isEqualToString:@"jpg"])   return [UIImage imageNamed:@"JPG_F"];
    
    
    return [UIImage imageNamed:@"UnknowFile"];
}

//-(UIImage *) FileThumbnail:(File*) currentFile
//{
//    UIImage *a = nil;
//    
//    return a;
//}


@end
