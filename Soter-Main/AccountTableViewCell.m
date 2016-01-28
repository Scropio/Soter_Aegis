//
//  AccountTableViewCell.m
//  Soter-Main
//
//  Created by Neil on 2015/7/15.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import "AccountTableViewCell.h"
#import "Language.h"
#import "LanguageViewController.h"

@implementation AccountTableViewCell

@synthesize Image_Thumbnail,Label_Title_Username,Label_Username,Label_Title_Comment,Label_Comment;

CGFloat sHeight;

- (void)awakeFromNib {
    // Initialization code
    self.Label_Title_Username.text = [Language get:@"AccountManager_UserName" alter:@"UserName"];
    self.Label_Title_Comment.text = [Language get:@"AccountManager_Comment" alter:@"Comment"];

    NSLog(@"AccountTableViewCell awakeFromNib");
    
//    CGFloat sHeight = self.frame.size.height;
    
    NSLog(@"%@",[NSString stringWithFormat:@"%f",self.frame.size.height]);
    
//    Image_Thumbnail.frame   = CGRectMake(4, 4, sHeight - 8, sHeight - 8);
//    
//    Label_Title_Username.frame = CGRectMake(Image_Thumbnail.frame.size.width + 8,
//                                            sHeight*2/3,
//                                            96,
//                                            24);
//    
//    Label_Username.frame = CGRectMake(Label_Title_Username.frame.origin.x + 4,
//                                      sHeight*2/3,
//                                      192,
//                                      24);
//    
//    Label_Title_Comment.frame = CGRectMake(Label_Title_Username.frame.origin.x,
//                                           sHeight/3,
//                                           96,
//                                           24);
//    
//    Label_Comment.frame = CGRectMake(Label_Username.frame.origin.x,
//                                     sHeight/3,
//                                     192,
//                                     24);
//
//    [Image_Thumbnail setBackgroundColor:[UIColor greenColor]];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [self UpdateData];
    
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        [Image_Thumbnail setImage:[UIImage imageNamed:@"4_button"]];
//        NSLog(@"AccountTableViewCell initWithStyle");


    }
  //  self.Label_Title_Username.text = [Language get:@"AccountManager_Service" alter:@"Service"];

    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier CellHeight:(float)cellHeight
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //        [Image_Thumbnail setImage:[UIImage imageNamed:@"4_button"]];
        NSLog(@"AccountTableViewCell initWithStyle");
    }
    
    sHeight = cellHeight;
    
    
  //  self.Label_Title_Username.text = [Language get:@"AccountManager_Service" alter:@"Service"];

    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark update data
-(void)UpdateData
{

     // self.Label_Title_Username.text = [Language get:@"AccountManager_Service" alter:@"Service"];
    
}

@end
