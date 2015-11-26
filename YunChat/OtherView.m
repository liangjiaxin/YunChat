//
//  OtherView.m
//  YunChat
//
//  Created by yiliu on 15/11/6.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "OtherView.h"

@implementation OtherView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *PictureBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 50, 50)];
        [PictureBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_colorMore_photo"] forState:UIControlStateNormal];
        [PictureBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_colorMore_photoSelected"] forState:UIControlStateHighlighted];
        [PictureBtn addTarget:self action:@selector(PictureBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:PictureBtn];
        
        UIButton *CameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(90, 10, 50, 50)];
        [CameraBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_colorMore_camera"] forState:UIControlStateNormal];
        [CameraBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_colorMore_cameraSelected"] forState:UIControlStateHighlighted];
        [CameraBtn addTarget:self action:@selector(CameraBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:CameraBtn];
        
        UIButton *PositionBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 10, 50, 50)];
        [PositionBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_colorMore_location"] forState:UIControlStateNormal];
        [PositionBtn setBackgroundImage:[UIImage imageNamed:@"chatBar_colorMore_locationSelected"] forState:UIControlStateHighlighted];
        [PositionBtn addTarget:self action:@selector(PositionBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:PositionBtn];
        
    }
    return self;
}

- (void)PictureBtn:(UIButton *)btn{
    [self.delegate ChoiceOther:0];
}

- (void)CameraBtn:(UIButton *)btn{
    [self.delegate ChoiceOther:1];
}

- (void)PositionBtn:(UIButton *)btn{
    [self.delegate ChoiceOther:2];
}

@end
