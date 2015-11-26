//
//  ChatCell.m
//  YunChat
//
//  Created by yiliu on 15/10/21.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "ChatCell.h"
#import "Auxiliary.h"

@implementation ChatCell


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
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, _backgroundImageView.bounds.size.width-15, _backgroundImageView.bounds.size.height-10)];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = 0;
        [_backgroundImageView addSubview:_contentLabel];
        
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _activity.hidden = YES;
        [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];//设置进度轮显示类型
        [self addSubview:_activity];
        
        _repeatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_repeatBtn setBackgroundImage:[UIImage imageNamed:@"messageSendFail"] forState:UIControlStateNormal];
        [_repeatBtn addTarget:self action:@selector(RepeatBtn:) forControlEvents:UIControlEventTouchUpInside];
        _repeatBtn.hidden = YES;
        [self addSubview:_repeatBtn];
    }
    return self;
}

- (void)setModel:(MessageModel *)model{
    _model = model;
    if(model.isSender){
        [self setContentStrY];
    }else{
        [self setContentStrZ];
    }
}

- (void)setContentStrZ{
    
    _headImageView.image = [UIImage imageNamed:@"head2"];
    
    UIImage *image = [UIImage imageNamed:@"chat_receiver_bg"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    
    _headImageView.frame = CGRectMake(10, 10, 30, 30);
    
    CGSize size = [Auxiliary CalculationHeightWidth:_model.content andSize:15 andCGSize:CGSizeMake(WIDE-115, 3000)];
    
    _backgroundImageView.frame = CGRectMake(45, 10, size.width+21, size.height+16);
    
    _contentLabel.frame = CGRectMake(13, 8, size.width, size.height);
    
    _contentLabel.text = _model.content;
    
    CGRect rect = self.frame;
    rect.size.height = size.height + 35;
    self.frame = rect;
    
}

- (void)setContentStrY{
    
    _headImageView.image = [UIImage imageNamed:@"head1"];
    
    UIImage *image = [UIImage imageNamed:@"chat_sender_bg"];
    image = [image stretchableImageWithLeftCapWidth:30 topCapHeight:30];
    _backgroundImageView.image = image;
    
    _headImageView.frame = CGRectMake(WIDE-40, 10, 30, 30);
    
    CGSize size = [Auxiliary CalculationHeightWidth:_model.content andSize:15 andCGSize:CGSizeMake(WIDE-115, 3000)];
    
    _backgroundImageView.frame = CGRectMake(WIDE-size.width-21-45, 10, size.width+21, size.height+16);
    
    _contentLabel.frame = CGRectMake(8, 8, size.width, size.height);
    
    _contentLabel.text = _model.content;
    
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
    rect.size.height = size.height + 35;
    self.frame = rect;
    
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
