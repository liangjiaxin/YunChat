//
//  CustomKeyboardView.m
//  YunChat
//
//  Created by yiliu on 15/11/4.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "CustomKeyboardView.h"

@implementation CustomKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *labFG = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDE, 0.2)];
        labFG.backgroundColor = RGBACOLOR(50, 50, 50, 1);
        [self addSubview:labFG];
        
        _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(50, 10, WIDE-140, 30)];
        _textView.layer.borderWidth = 1;
        _textView.layer.borderColor = RGBACOLOR(230, 230, 230, 1).CGColor;
        _textView.layer.cornerRadius = 4;
        _textView.layer.masksToBounds = YES;
        _textView.textColor = [UIColor blackColor];
        _textView.isScrollable = NO;
        _textView.minNumberOfLines = 1;
        _textView.maxNumberOfLines = 20;
        _textView.font = [UIFont systemFontOfSize:14.0f];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.placeholder = @"点击输入内容";
        _textView.returnKeyType = UIReturnKeySend;
        [self addSubview:_textView];
        
        _StartVoiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 10, WIDE-140, 30)];
        _StartVoiceBtn.hidden = YES;
        [_StartVoiceBtn setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
        [_StartVoiceBtn setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordSelectedBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
        [_StartVoiceBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [_StartVoiceBtn addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_StartVoiceBtn];
        
        _VoiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        [_VoiceBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_record"] forState:UIControlStateNormal];
        [_VoiceBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
        [_VoiceBtn addTarget:self action:@selector(VoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_VoiceBtn];
        
        _ExpressionBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDE-80, 10, 30, 30)];
        [_ExpressionBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_face"] forState:UIControlStateNormal];
        [_ExpressionBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
        [_ExpressionBtn addTarget:self action:@selector(ExpressionBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_ExpressionBtn];
        
        _OtherBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDE-40, 10, 30, 30)];
        [_OtherBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_more"] forState:UIControlStateNormal];
        [_OtherBtn addTarget:self action:@selector(OtherBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_OtherBtn];
        
    }
    return self;
}

//语音键盘
- (void)VoiceBtn:(UIButton *)btn{
    if(btn.selected){
        btn.selected = NO;
        _textView.hidden = NO;
        _StartVoiceBtn.hidden = YES;
        [self.delegate ChoiceWrittenWordsKeyboard];
    }else{
        btn.selected = YES;
        _textView.hidden = YES;
        _StartVoiceBtn.hidden = NO;
        [self.delegate ChoiceVoiceKeyboard];
    }
}

//表情键盘
- (void)ExpressionBtn:(UIButton *)btn{
    if(btn.selected){
        btn.selected = NO;
        [self.delegate ChoiceWrittenWordsKeyboard];
    }else{
        btn.selected = YES;
        [self.delegate ChoiceExpressionKeyboard];
    }
    _VoiceBtn.selected = NO;
    _textView.hidden = NO;
    _StartVoiceBtn.hidden = YES;
}

//其他键盘
- (void)OtherBtn:(UIButton *)btn{
    [self.delegate ChoiceOtherKeyboard];
}

//按下录音键开始录音
- (void)recordButtonTouchDown
{
    [self.delegate StartVoice];
}

//松开录音键发送录音
- (void)recordButtonTouchUpInside
{
    [self.delegate CompleteVoice];
}

#pragma -mark HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect rr = self.frame;
    rr.size.height -= diff;
    rr.origin.y += diff;
    self.frame = rr;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [self.delegate SendChat];
    return YES;
}

@end
