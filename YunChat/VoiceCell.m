//
//  VoiceCell.m
//  YunChat
//
//  Created by yiliu on 15/11/18.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "VoiceCell.h"
#import "MBProgressHUD.h"
#import "EMVoiceConverter.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@implementation VoiceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 10, 70, 30)];
        _backgroundImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_backgroundImageView];
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        _headImageView.layer.cornerRadius = 15;
        _headImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_headImageView];
        
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 30, 30)];
        [_backgroundImageView addSubview:_contentImageView];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 20, 30)];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont systemFontOfSize:14];
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
        
        UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PlayVoice:)];
        [_backgroundImageView addGestureRecognizer:tapImageView];
        
    }
    return self;
}

- (void)setModel:(MessageModel *)model{
    _model = model;
    if(model.isSender){
        [self setVoiceY];
    }else{
        [self setVoiceZ];
    }
}

- (void)setVoiceZ{
    
    _contentLabel.text = [NSString stringWithFormat:@"%tu",_model.time];
    _headImageView.image = [UIImage imageNamed:@"head2"];
    
    UIImage *image = [UIImage imageNamed:@"chat_receiver_bg"];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:30];
    _backgroundImageView.image = image;
    
    _headImageView.frame = CGRectMake(10, 10, 30, 30);
    
    _backgroundImageView.frame = CGRectMake(45, 5, 80, 40);
    
    _contentImageView.frame = CGRectMake(10, 5, 30, 30);
    
    _contentLabel.frame = CGRectMake(45, 5, 30, 30);
    
    _contentImageView.image = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
    
    CGRect rect = self.frame;
    rect.size.height = 50;
    self.frame = rect;
    
}

- (void)setVoiceY{
    
    _contentLabel.text = [NSString stringWithFormat:@"%tu",_model.time];
    _headImageView.image = [UIImage imageNamed:@"head1"];
    
    UIImage *image = [UIImage imageNamed:@"chat_sender_bg"];
    image = [image stretchableImageWithLeftCapWidth:30 topCapHeight:30];
    _backgroundImageView.image = image;
    
    _headImageView.frame = CGRectMake(WIDE-40, 10, 30, 30);
    
    _backgroundImageView.frame = CGRectMake(WIDE-80-45, 5, 80, 40);
    
    _contentImageView.frame = CGRectMake(40, 5, 30, 30);
    
    _contentLabel.frame = CGRectMake(5, 5, 30, 30);
    
    _contentImageView.image = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
    
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
    rect.size.height = 50;
    self.frame = rect;
    
}

//播放音频
- (void)PlayVoice:(UITapGestureRecognizer *)tap{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"routerEvent" object:@{@"VoiceModel":_model,@"Type":@"PlayVoice"}];
    
    [self chatAudioCellBubblePressed:_model];
}

- (void)RepeatBtn:(UIButton *)btn{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"routerEvent" object:@{@"Cell":self,@"Type":@"Repeat"}];
}

// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(MessageModel *)model{
    id <IEMFileMessageBody> body = [model.message.messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
    if (downloadStatus == EMAttachmentDownloading) {
        [self showHint:@"正在下载语音文件"];
        return;
    }
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
        [self showHint:@"语音文件下载失败,正在重新下载"];
        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        return;
    }
    // 播放音频
    if (model.type == eMessageBodyType_Voice) {
        
        NSString *aFilePath = model.localPath;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *wavFilePath = [[aFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
        //如果转换后的wav文件不存在, 则去转换一下
        if (![fileManager fileExistsAtPath:wavFilePath]) {
            BOOL covertRet = [self convertAMR:aFilePath toWAV:wavFilePath];
            if(!covertRet){
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"转换音频文件失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return;
            }
        }
        NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:wavFilePath];
        
        _timerNum = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        [[SoundRecord sharedInstance] isPlay];
        [SoundRecord sharedInstance].delegate = self;
        [[SoundRecord sharedInstance] play:wavUrl];
        
    }
}

//播放失败
- (void)PlayVoiceFailure{
    [_timer invalidate];
    if(_model.isSender){
        _contentImageView.image = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
    }else{
        _contentImageView.image = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
    }
}

//播放完成
- (void)PlayVoiceComplete{
    [_timer invalidate];
    if(_model.isSender){
        _contentImageView.image = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
    }else{
        _contentImageView.image = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
    }
}

//定时器
- (void)timerFired:(NSTimer *)time{
    _timerNum++;
    _timerNum = _timerNum > 3 ? 0 : _timerNum;
    
    NSString *imageName;
    if(_model.isSender){
        imageName = [NSString stringWithFormat:@"chat_sender_audio_playing_00%tu",_timerNum];
    }else{
        imageName = [NSString stringWithFormat:@"chat_receiver_audio_playing00%tu",_timerNum];
    }
    _contentImageView.image = [UIImage imageNamed:imageName];
}

- (void)showHint:(NSString *)hint{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}
    
- (BOOL)convertAMR:(NSString *)amrFilePath toWAV:(NSString *)wavFilePath{
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
    if (isFileExists) {
        [EMVoiceConverter amrToWav:amrFilePath wavSavePath:wavFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
        if (isFileExists) {
            ret = YES;
        }
    }
    return ret;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
