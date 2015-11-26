//
//  YunChatListCell.h
//  YunChat
//
//  Created by yiliu on 15/10/20.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YunChatListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageNumbLabel;

@end
