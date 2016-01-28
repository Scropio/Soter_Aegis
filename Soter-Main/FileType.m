//
//  FileType.m
//  Soter-Main
//
//  Created by Neil on 2015/8/26.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "FileType.h"

@implementation FileType


/* !Get thumbnail by file extension
    @param Type 
        File's extension
    @param ImageSize
*/

+(UIImage *) getThumbnail:(NSString *)Type ImageSize:(BOOL)ImageSize
{
    UIImage* returnThumbnail;
    
    Type = [Type uppercaseString];
    
         if ([Type isEqualToString:@"PDF"])     returnThumbnail = [UIImage imageNamed:@"PDF"];
    else if ([Type isEqualToString:@"JPG"])     returnThumbnail = [UIImage imageNamed:@"JPG_S"];
    else if ([Type isEqualToString:@"PNG"])     returnThumbnail = [UIImage imageNamed:@"PNG"];
    else if ([Type isEqualToString:@"GIF"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"DOC"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"DOCX"])    returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"XLS"])     returnThumbnail = [UIImage imageNamed:@"XLSX"];
    else if ([Type isEqualToString:@"XLSX"])    returnThumbnail = [UIImage imageNamed:@"XLSX"];
    else if ([Type isEqualToString:@"PPT"])     returnThumbnail = [UIImage imageNamed:@"PPTX"];
    else if ([Type isEqualToString:@"PPTX"])    returnThumbnail = [UIImage imageNamed:@"PPTX"];
    else if ([Type isEqualToString:@"PDF"])     returnThumbnail = [UIImage imageNamed:@"PDF"];
    else if ([Type isEqualToString:@"WAV"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"MP3"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"AAC"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"MP4"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"MPG"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"MOV"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"FLV"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else if ([Type isEqualToString:@"ZIP"])     returnThumbnail = [UIImage imageNamed:@"BMP"];
    else                                        returnThumbnail = [UIImage imageNamed:@"UnknowFile"];

    return returnThumbnail;
}

@end


