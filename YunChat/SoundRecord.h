//
//  SoundRecord.h
//  YunChat
//
//  Created by yiliu on 15/11/13.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol SoundRecordDelegate <NSObject>

@optional
/**
 *录音完成
 */
- (void)SoundRecordStop:(BOOL)convertResult andPath:(NSString *)path andTime:(NSInteger)times;

/**
 *播放失败
 */
- (void)PlayVoiceFailure;

/**
 *播放完成
 */
- (void)PlayVoiceComplete;

@end

@interface SoundRecord : NSObject<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic, weak) id <SoundRecordDelegate> delegate;

+ (SoundRecord *)sharedInstance;

@property (nonatomic,strong) AVAudioRecorder *audioRecorder; //音频录音机

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;     //音频播放器

@property (nonatomic,strong) NSURL *pathUrl;     //音频路径

@property (nonatomic,strong) NSDate *starTime;     //开始录音的时间
@property (nonatomic,strong) NSDate *EndTime;      //结束录音的时间


/**
 *  录音
 *
 *  @param sender 录音
 */
- (void)startRecord;

/**
 *  取消录音
 *
 *  @param sender 取消录音
 */
- (void)cancelRecord;

/**
 *  停止录音
 *
 *  @param sender 停止录音
 */
- (void)stop;

/**
 *  播放
 *
 *  @param sender 播放
 */
- (void)play:(NSURL *)path;

/**
 *  是否正在播放，是就停止播放
 *
 *  @param sender 停止播放
 */
- (void)isPlay;

@end
