//
//  SoundRecord.m
//  YunChat
//
//  Created by yiliu on 15/11/13.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "SoundRecord.h"

#import "EMVoiceConverter.h"

static SoundRecord *soundRecord = nil;

@implementation SoundRecord

+ (SoundRecord *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundRecord = [[self alloc] init];
    });
    
    return soundRecord;
}

//录音文件设置
- (NSDictionary *)getAudioSetting
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                   nil];
    return recordSetting;
}

//录音存储路径
- (NSString *)getSavePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [paths objectAtIndex:0];
    filePath = [filePath stringByAppendingPathComponent:@"test.wav"];// 保存文件的名称
    NSLog(@"录音存储路径:%@",filePath);
    return filePath;
}

//录音存储路径
- (NSString *)getSavePathAmr
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [paths objectAtIndex:0];
    filePath = [filePath stringByAppendingPathComponent:@"luyin.amr"];//保存文件的名称
    return filePath;
}

//计算时间差
- (NSInteger)timeDifference
{
    //创建日期格式化对象
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //取两个日期对象的时间间隔：
    //这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:typedef double NSTimeInterval;
    NSTimeInterval time=[_EndTime timeIntervalSinceDate:_starTime];
    
    int miao=((int)time)%(3600*24)%3600%3600;
    
    return miao;
}

- (AVAudioRecorder *)audioRecorder
{
    if (_audioRecorder) {
        _audioRecorder = nil;
    }
    NSError *error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:[self getSavePath]] settings:[self getAudioSetting] error:&error];
    [_audioRecorder prepareToRecord];
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES; //是否启用录音测量，如果启用录音测量可以获得录音分贝等数据信息
    if (error) {
        NSLog(@"创建录音机对象发生错误:%@",error.localizedDescription);
        return nil;
    }
    return _audioRecorder;
}

- (AVAudioPlayer *)audioPlayer
{
    NSError *error = nil;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_pathUrl error:&error];
    _audioPlayer.delegate = self;
    if (error) {
        NSLog(@"创建音频播放器对象发生错误:%@",error.localizedDescription);
        [self.delegate PlayVoiceFailure];
        return nil;
    }
    return _audioPlayer;
}

//录音
- (void)startRecord{
    if (![_audioRecorder isRecording]) {
        [self.audioRecorder record];
        _starTime = [NSDate date];
        NSLog(@"开始录音");
    }
}

//取消录音
- (void)cancelRecord{
    _audioRecorder.delegate = nil;
    if ([_audioRecorder isRecording]) {
        [_audioRecorder stop];
        NSLog(@"取消录音");
    }
    _audioRecorder = nil;
}

//停止录音
- (void)stop{
    [_audioRecorder stop];
    _EndTime = [NSDate date];
    NSLog(@"停止录音");
}

#pragma mark - AVAudioRecorderDelegate
//录音成功
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"录音成功");
    BOOL isToAmr = [EMVoiceConverter wavToAmr:[self getSavePath] amrSavePath:[self getSavePathAmr]];
    if(!isToAmr){
        //删除录的wav
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[self getSavePath] error:nil];
        [self.delegate SoundRecordStop:YES andPath:[self getSavePathAmr] andTime:[self timeDifference]];
    }else{
        [self.delegate SoundRecordStop:NO andPath:[self getSavePathAmr] andTime:[self timeDifference]];
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"转换录音文件失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

//录音失败
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"录音失败:%@",error.localizedDescription);
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"录音失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
}


////////////////////////////////////播放录音////////////////////////////////////
////////////////////////////////////播放录音////////////////////////////////////
////////////////////////////////////播放录音////////////////////////////////////
////////////////////////////////////播放录音////////////////////////////////////
//播放
- (void)play:(NSURL *)path{
    _pathUrl = path;
    [self.audioPlayer play];
    NSLog(@"开始播放录音");
}

//是否正在播放，是就停止播放
- (void)isPlay{
    if([_audioPlayer isPlaying]){
        [_audioPlayer stop];
        [self.delegate PlayVoiceComplete];
        self.delegate = nil;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag{
    //播放结束时执行的动作
    [self.delegate PlayVoiceComplete];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    //解码错误执行的动作
}
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player{
    //处理中断的代码
}
- (void)audioPlayerEndInteruption:(AVAudioPlayer*)player{
    //处理中断结束的代码
}

@end
