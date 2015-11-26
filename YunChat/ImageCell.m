//
//  ImageCell.m
//  YunChat
//
//  Created by yiliu on 15/11/18.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "ImageCell.h"
#import "UIImageView+EMWebCache.h"

@implementation ImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 10, WIDE-50, 30)];
        _backgroundImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_backgroundImageView];
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        _headImageView.layer.cornerRadius = 15;
        _headImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_headImageView];
        
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _contentImageView.userInteractionEnabled = YES;
        [_backgroundImageView addSubview:_contentImageView];
        
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _activity.hidden = YES;
        [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];//设置进度轮显示类型
        [self addSubview:_activity];
        
        _repeatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_repeatBtn setBackgroundImage:[UIImage imageNamed:@"messageSendFail"] forState:UIControlStateNormal];
        [_repeatBtn addTarget:self action:@selector(RepeatBtn:) forControlEvents:UIControlEventTouchUpInside];
        _repeatBtn.hidden = YES;
        [self addSubview:_repeatBtn];
        
        UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chaImage:)];
        [_contentImageView addGestureRecognizer:tapImageView];
        
    }
    return self;
}

- (void)setModel:(MessageModel *)model{
    _model = model;
    if(model.isSender){
        [self setImageStrY];
    }else{
        [self setImageStrZ];
    }
}

- (void)setImageStrZ{
    
    _headImageView.image = [UIImage imageNamed:@"head2"];
    
    UIImage *image = [UIImage imageNamed:@"chat_receiver_bg"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    
    _headImageView.frame = CGRectMake(10, 10, 30, 30);
    
    NSArray *ary = [self jisuanbili:_model.size];
    
    _backgroundImageView.frame = CGRectMake(45, 10, [ary[0] floatValue]+21, [ary[1] floatValue]+16);
    
    _contentImageView.frame = CGRectMake(13, 8, [ary[0] floatValue], [ary[1] floatValue]);
    
    [_contentImageView sd_setImageWithURL:_model.imageRemoteURL placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    CGRect rect = self.frame;
    rect.size.height = [ary[1] floatValue] + 35;
    self.frame = rect;
    
}

- (void)setImageStrY{
    
    _headImageView.image = [UIImage imageNamed:@"head1"];
    
    UIImage *image = [UIImage imageNamed:@"chat_sender_bg"];
    image = [image stretchableImageWithLeftCapWidth:30 topCapHeight:30];
    _backgroundImageView.image = image;
    
    _headImageView.frame = CGRectMake(WIDE-40, 10, 30, 30);
    
    NSArray *ary = [self jisuanbili:_model.size];
    
    _backgroundImageView.frame = CGRectMake(WIDE-[ary[0] floatValue]-45-21, 10, [ary[0] floatValue]+21, [ary[1] floatValue]+16);
    
    _contentImageView.frame = CGRectMake(8, 8, [ary[0] floatValue], [ary[1] floatValue]);
    
    _contentImageView.image = [UIImage imageWithContentsOfFile:_model.localPath];
    
    if(_model.isSender && (_model.message.deliveryState == 0 || _model.message.deliveryState == 1)){
        
        _repeatBtn.hidden = YES;
        _activity.hidden = NO;
        [_activity startAnimating];
        _activity.frame = CGRectMake(_backgroundImageView.frame.origin.x-20, _backgroundImageView.frame.origin.y+_backgroundImageView.frame.size.height/2-7.5, 15, 15);
        
    }else if(_model.isSender && _model.message.deliveryState == 3){
        
        _repeatBtn.hidden = NO;
        _activity.hidden = YES;
        [_activity stopAnimating];
        _repeatBtn.frame = CGRectMake(_backgroundImageView.frame.origin.x-20, _backgroundImageView.frame.origin.y+_backgroundImageView.frame.size.height/2-7.5, 15, 15);
        
    }else{
        
        _repeatBtn.hidden = YES;
        _activity.hidden = YES;
        [_activity stopAnimating];
        
    }

    CGRect rect = self.frame;
    rect.size.height = [ary[1] floatValue] + 35;
    self.frame = rect;
    
}

- (NSArray *)jisuanbili:(CGSize)size{
    
    float Jchang;
    float Jkuan;
    if(size.width > 100 || size.height > 100){
        if(size.width > size.height){
            float bili = 100/size.width;
            Jkuan = size.height * bili;
            Jchang = 100;
        }else{
            float bili = 100/size.height;
            Jchang = size.width * bili;
            Jkuan = 100;
        }
    }else{
        Jchang = size.width;
        Jkuan = size.height;
    }
    
    NSString *JJchang = [NSString stringWithFormat:@"%f",Jchang];
    NSString *JJkuan = [NSString stringWithFormat:@"%f",Jkuan];
    NSArray *ary = [[NSArray alloc] initWithObjects:JJchang,JJkuan, nil];
    return ary;
    
}

- (void)chaImage:(UITapGestureRecognizer *)tap{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDE, HIGH)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.userInteractionEnabled = YES;
    [self.window addSubview:imageView];
    
    UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseImage:)];
    [imageView addGestureRecognizer:tapImageView];
    
    if(_model.isSender){
        imageView.image = [UIImage imageWithContentsOfFile:_model.localPath];
    }else{
        [imageView sd_setImageWithURL:_model.imageRemoteURL placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        }];
    }
    
}

- (void)CloseImage:(UITapGestureRecognizer *)tap{
    [tap.view removeFromSuperview];
}

- (void)RepeatBtn:(UIButton *)btn{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"routerEvent" object:@{@"Cell":self,@"Type":@"Repeat"}];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
