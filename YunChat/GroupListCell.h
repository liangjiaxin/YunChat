//
//  GroupListCell.h
//  YunChat
//
//  Created by yiliu on 16/1/8.
//  Copyright © 2016年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *number;

@end
