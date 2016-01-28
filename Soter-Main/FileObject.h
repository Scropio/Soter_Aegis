//
//  FileObject.h
//  Soter-Main
//
//  Created by Neil on 2015/7/3.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileObject : NSObject

@property (nonatomic)  NSString *FileName;
@property (nonatomic)  NSString *FileExtension;

@property (nonatomic)  float    FileSize;

@end
