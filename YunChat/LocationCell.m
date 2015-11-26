//
//  LocationCell.m
//  YunChat
//
//  Created by yiliu on 15/11/19.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell

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
        
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 95, 95)];
        _contentImageView.userInteractionEnabled = YES;
        _contentImageView.image = [UIImage imageNamed:@"chat_location_preview"];
        [_backgroundImageView addSubview:_contentImageView];
        
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 64, 85, 31)];
        _locationLabel.font = [UIFont systemFontOfSize:10];
        _locationLabel.textColor = [UIColor whiteColor];
        _locationLabel.numberOfLines = 2;
        [_contentImageView addSubview:_locationLabel];
        
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
    
    _backgroundImageView.frame = CGRectMake(45, 10, 116, 111);
    
    _contentImageView.frame = CGRectMake(13, 8, 95, 95);
    
    _locationLabel.text = _model.address;
    
    CGRect rect = self.frame;
    rect.size.height = 135;
    self.frame = rect;
    
}

- (void)setImageStrY{
    
    _headImageView.image = [UIImage imageNamed:@"head1"];
    
    UIImage *image = [UIImage imageNamed:@"chat_sender_bg"];
    image = [image stretchableImageWithLeftCapWidth:30 topCapHeight:30];
    _backgroundImageView.image = image;
    
    _headImageView.frame = CGRectMake(WIDE-40, 10, 30, 30);
    
    _backgroundImageView.frame = CGRectMake(WIDE-116-45, 10, 116, 111);
    
    _contentImageView.frame = CGRectMake(8, 8, 95, 95);
    
    _locationLabel.text = _model.address;
    
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
    rect.size.height = 135;
    self.frame = rect;
    
}

- (void)chaImage:(UITapGestureRecognizer *)tap{
    NSString *latitude = [NSString stringWithFormat:@"%f",_model.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",_model.longitude];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"routerEvent" object:@{@"latitude":latitude,@"longitude":longitude,@"Type":@"SeeLocation"}];
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
