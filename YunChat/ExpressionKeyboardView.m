//
//  ExpressionKeyboardView.m
//  YunChat
//
//  Created by yiliu on 15/11/5.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "ExpressionKeyboardView.h"
#import "EmojiEmoticons.h"

@implementation ExpressionKeyboardView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor whiteColor];
        
        _allEmoticonsAry = [EmojiEmoticons allEmoticons];
        _index = 0;
        
        float b = 30;
        float k = (WIDE-b*8)/9;
        
        float g = 65/6;
        
        for (int i=0; i<5; i++) {
            
            for (int y=0; y<8; y++){
                
                if(_index < _allEmoticonsAry.count){
                    UIButton *btnExpressionKeyBoard = [[UIButton alloc] initWithFrame:CGRectMake(k+(k+b)*y, g+(g+b)*i, b, b)];
                    btnExpressionKeyBoard.tag = _index;
                    btnExpressionKeyBoard.titleLabel.font = [UIFont systemFontOfSize:25];
                    [btnExpressionKeyBoard setTitle:_allEmoticonsAry[_index] forState:UIControlStateNormal];
                    [btnExpressionKeyBoard addTarget:self action:@selector(ChoiceExpression:) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:btnExpressionKeyBoard];
                    _index++;
                }
            }
            
        }
        
        UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDE-b*2-k, g+(g+30)*4, b*2, b)];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [sendBtn setBackgroundImage:[UIImage imageNamed:@"gender_bg_p"] forState:UIControlStateNormal];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn addTarget:self action:@selector(SendExpression:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendBtn];
        
    }
    return self;
}

- (void)ChoiceExpression:(UIButton *)btn{
    [self.delegate ChoiceExpression:_allEmoticonsAry[btn.tag]];
}

- (void)SendExpression:(UIButton *)btn{
    [self.delegate SendExpression];
}

@end
