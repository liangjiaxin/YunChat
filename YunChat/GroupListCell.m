//
//  GroupListCell.m
//  YunChat
//
//  Created by yiliu on 16/1/8.
//  Copyright © 2016年 mushoom. All rights reserved.
//

#import "GroupListCell.h"

@implementation GroupListCell

- (void)awakeFromNib {
    self.headImageView.layer.cornerRadius = 20;
    self.headImageView.layer.masksToBounds = YES;
    
    self.number.layer.cornerRadius = 10;
    self.number.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
