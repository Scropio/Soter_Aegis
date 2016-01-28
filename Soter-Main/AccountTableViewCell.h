//
//  AccountTableViewCell.h
//  Soter-Main
//
//  Created by Neil on 2015/7/15.
//  Copyright (c) 2015年 Taiyuta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *Image_Thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *Label_Username;
@property (weak, nonatomic) IBOutlet UILabel *Label_Comment;
@property (weak, nonatomic) IBOutlet UILabel *Label_Title_Username;
@property (weak, nonatomic) IBOutlet UILabel *Label_Title_Comment;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier CellHeight:(float)cellHeight;

@end
