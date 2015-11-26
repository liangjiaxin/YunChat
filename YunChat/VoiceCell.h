//
//  VoiceCell.h
//  YunChat
//
//  Created by yiliu on 15/11/18.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
#import "SoundRecord.h"

@interface VoiceCell : UITableViewCell<SoundRecordDelegate>

/**
 *气泡
 */
@property (nonatomic,strong) UIImageView *backgroundImageView;

/**
 *头像
 */
@property (nonatomic,strong) UIImageView *headImageView;

/**
 *内容(文字)
 */
@property (nonatomic,strong) UILabel     *contentLabel;

/**
 *内容(图片)
 */
@property (nonatomic,strong) UIImageView *contentImageView;

/**
 *菊花
 */
@property (nonatomic,strong) UIActivityIndicatorView *activity;

/**
 *重发按钮
 */
@property (nonatomic,strong) UIButton *repeatBtn;

/**
 *消息内容
 */
@property (nonatomic,strong) MessageModel *model;


@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) NSInteger timerNum;


@end
