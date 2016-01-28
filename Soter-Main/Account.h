//
//  Account.h
//  TableViewExpand
//
//  Created by Neil on 2015/5/12.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (nonatomic,strong) NSString *ID;
@property (nonatomic,strong) NSString *Name;
@property (nonatomic,strong) NSString *Username;
@property (nonatomic,strong) NSString *Password;
@property (nonatomic,strong) NSString *Comment;
@property (nonatomic)        int      Sequence;

-(id) initWithParams : (NSString*)_Name Username:(NSString *)_Username Password:(NSString*)_Password Comment:(NSString *)_Comment;

@end
