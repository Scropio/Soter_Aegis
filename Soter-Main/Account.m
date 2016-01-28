//
//  Account.m
//  TableViewExpand
//
//  Created by Neil on 2015/5/12.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "Account.h"

@implementation Account

@synthesize ID,Name,Username,Password,Comment,Sequence;

-(id)init
{
    self = [super init];
    if(self)
    {
        ID       = [[NSString alloc] init];
        Name     = [[NSString alloc] init];
        Username = [[NSString alloc] init];
        Password = [[NSString alloc] init];
        Comment  = [[NSString alloc] init];
        Sequence = 0;
    }
    return self;
}

-(id) initWithParams :(NSString *)_ID Name:(NSString*)_Name Username:(NSString *)_Username Password:(NSString*)_Password Comment:(NSString *)_Comment
{
    self = [super init];
    if(self)
    {
        ID       = _ID;
        Name     = _Name;
        Username = _Username;
        Password = _Password;
        Comment  = _Comment;
    }
    
    return self;
}



@end