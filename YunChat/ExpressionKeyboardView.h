//
//  ExpressionKeyboardView.h
//  YunChat
//
//  Created by yiliu on 15/11/5.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExpressionKeyboardDelegate <NSObject>

/**
 *发送内容
 */
- (void)SendExpression;

/**
 *选择表情
 */
- (void)ChoiceExpression:(NSString *)expression;

@end

@interface ExpressionKeyboardView : UIView

@property (nonatomic, weak) id <ExpressionKeyboardDelegate> delegate;

@property (nonatomic,strong) NSArray   *allEmoticonsAry;
@property (nonatomic,assign) NSInteger index;

@end
