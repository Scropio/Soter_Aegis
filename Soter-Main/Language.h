//
//  Language.h
//  Soter-Main
//
//  Created by ＨＥＭＬＹ on 2015/12/18.
//  Copyright © 2015年 Taiyuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Language : NSObject


+(void)initialize;
+(void)setLanguage:(NSString *)l;
+(NSString *)get:(NSString *)key alter:(NSString *)alternate;

@end
