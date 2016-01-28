//
//  User.m
//  Soter-Main
//
//  Created by Neil on 2015/6/15.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize ID,Name,Username,Password,Comment;

-(id) init
{
    if (self =[super init])
    {
        self.ID         = -1;
        self.Name       = [[NSString alloc]init];
        self.Username   = [[NSString alloc]init];
        self.Password   = [[NSString alloc]init];
        self.Comment    = [[NSString alloc]init];
    }
    return self;
}

-(id) init:(int)_ID NAME:(NSString*)_Name USERNAME:(NSString*)_Username PASSWORD:(NSString*)_Password COMMENT:(NSString*)_Comment
{
    if (self =[super init])
    {
        self.ID         = _ID;
        self.Name       = _Name;
        self.Username   = _Username;
        self.Password   = _Password;
        self.Comment    = _Comment;
    }
    return self;
}

@end
