//
//  LocationCell.h
//  YunChat
//
//  Created by yiliu on 15/11/19.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface LocationCell : UITableViewCell

/**
 *气泡
 */
@property (nonatomic,strong) UIImageView *backgroundImageView;

/**
 *头像
 */
@property (nonatomic,strong) UIImageView *headImageView;

/**
 *地图图片
 */
@property (nonatomic,strong) UIImageView *contentImageView;

/**
 *地点
 */
@property (nonatomic,strong) UILabel *locationLabel;

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

@end
