//
//  XNTabBarController.h
//  车辆监控1.1版本
//
//  Created by Allen_12138 on 15-1-23.
//  Copyright (c) 2015年 粤峰通讯科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTabBarController : UITabBarController

@property (nonatomic,strong) UIImageView *myView;

@property (nonatomic,strong) UIImageView *loginView;

/**
 *改变选中的行
 */
- (void)setSelectButton:(NSInteger)tag;

@end
