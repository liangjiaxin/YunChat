//
//  CustomKeyboardView.h
//  YunChat
//
//  Created by yiliu on 15/11/4.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@protocol CustomKeyboardDelegate <NSObject>

/**
 *发送文字
 */
- (void)SendChat;

/**
 *开始录音
 */
- (void)StartVoice;

/**
 *完成录音
 */
- (void)CompleteVoice;

/**
 *表情键盘
 */
- (void)ChoiceExpressionKeyboard;

/**
 *文字键盘
 */
- (void)ChoiceWrittenWordsKeyboard;

/**
 *录音键盘
 */
- (void)ChoiceVoiceKeyboard;

/**
 *其他
 */
- (void)ChoiceOtherKeyboard;

@end

@interface CustomKeyboardView : UIView<HPGrowingTextViewDelegate,UITextViewDelegate>

@property (nonatomic, weak) id <CustomKeyboardDelegate> delegate;

//文字内容
@property (nonatomic,strong) HPGrowingTextView *textView;

//开始录音
@property (nonatomic,strong) UIButton *StartVoiceBtn;

//录音
@property (nonatomic,strong) UIButton *VoiceBtn;

//文字
@property (nonatomic,strong) UIButton *ExpressionBtn;

//其他
@property (nonatomic,strong) UIButton *OtherBtn;

@end
