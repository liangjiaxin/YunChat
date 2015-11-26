//
//  YunChatListCell.m
//  YunChat
//
//  Created by yiliu on 15/10/20.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "YunChatListCell.h"

@implementation YunChatListCell

- (void)awakeFromNib {
    self.headImageView.layer.cornerRadius = 20;
    self.headImageView.layer.masksToBounds = YES;
    
    self.messageNumbLabel.layer.cornerRadius = 10;
    self.messageNumbLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
