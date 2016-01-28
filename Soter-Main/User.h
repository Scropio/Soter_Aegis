//
//  User.h
//  Soter-Main
//
//  Created by Neil on 2015/6/15.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

-(id) init;

-(id) init:(int)_ID NAME:(NSString*)_Name USERNAME:(NSString*)_Username PASSWORD:(NSString*)_Password COMMENT:(NSString*)_Comment;

@property int ID;
@property NSString* Name;
@property NSString* Username;
@property NSString* Password;
@property NSString* Comment;

@end
