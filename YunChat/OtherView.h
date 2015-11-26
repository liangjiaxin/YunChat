//
//  OtherView.h
//  YunChat
//
//  Created by yiliu on 15/11/6.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OtherDelegate <NSObject>

/**
 *选择
 *0：相册
 *1：相机
 *2：位置
 */
- (void)ChoiceOther:(NSInteger)type;

@end

@interface OtherView : UIView

@property (nonatomic, weak) id <OtherDelegate> delegate;

@end
