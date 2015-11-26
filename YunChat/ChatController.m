//
//  ChatController.m
//  YunChat
//
//  Created by yiliu on 15/10/21.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "ChatController.h"
#import "ChatCell.h"
#import "ImageCell.h"
#import "VoiceCell.h"
#import "LocationCell.h"
#import "ChatTimeCell.h"
#import "EaseMob.h"
#import "NSDate+Category.h"
#import "MessageModelManager.h"
#import "MessageModel.h"
#import "CustomKeyboardView.h"
#import "ChatSendHelper.h"
#import "SoundRecord.h"
#import "LocationViewController.h"
#import "ExpressionKeyboardView.h"
#import "OtherView.h"

@interface ChatController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,EMCallManagerDelegate,CustomKeyboardDelegate,ExpressionKeyboardDelegate,OtherDelegate,SoundRecordDelegate,LocationViewDelegate>{
    dispatch_queue_t _messageQueue;
}

@property (assign, nonatomic)  BOOL             isChatGroup;
@property (strong, nonatomic)  NSDate           *chatTagDate;
@property (strong, nonatomic)  NSMutableArray   *messages;
@property (nonatomic,strong)   NSMutableArray   *dataSource;
@property (strong, nonatomic)  EMConversation   *conversation;//会话管理者
@property (strong, nonatomic)  CustomKeyboardView   *CustomKeyboardView;  //说话框
@property (strong, nonatomic)  ExpressionKeyboardView   *ExpressionKeyView;//表情键盘
@property (strong, nonatomic)  OtherView        *otherView; //其他
@property (strong, nonatomic)  NSString         *chatterID;

@end

@implementation ChatController

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup{
    EMConversationType type = isGroup ? eConversationTypeGroupChat : eConversationTypeChat;
    self = [super init];
    if (self) {
        _chatterID = chatter;
        _isChatGroup = isGroup;
        //根据接收者的username获取当前会话的管理者
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter
                                                                    conversationType:type];
        [_conversation markAllMessagesAsRead:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _chatterID;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.chatTableView.tableFooterView = [[UIView alloc] init];
    [self.chatTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:self.CustomKeyboardView];
    
    _messages = [[NSMutableArray alloc] initWithCapacity:0];
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    
    //通过会话管理者获取已收发消息
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    [self loadMoreMessagesFrom:timestamp count:20 append:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];//在这里注册通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routerEvent:) name:@"routerEvent" object:nil];//重发de通知
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseKeyboard)];
    [self.view addGestureRecognizer:tap];

}

#pragma -mark UITableViewDelegate,UITableViewDataSource
//设置每个分区的单元格数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

//设置分区的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        
        static NSString *reuseIdetify = @"ChatTimeCell";
        ChatTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
        if (cell ==nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reuseIdetify owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.timeTitle.text = obj;
        
        return cell;
    }else{
        
        MessageModel *model = (MessageModel *)obj;
        
        if(model.type == 1){
            
            static NSString *reuseIdetify = @"ChatCell";
            ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
            if (cell ==nil) {
                cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.model = model;
            
            return cell;
            
        }else if(model.type == 2){
            
            static NSString *reuseIdetify = @"ImageCell";
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
            if (cell ==nil) {
                cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.model = model;
            
            return cell;
            
        }else if(model.type == 4){
            
            static NSString *reuseIdetify = @"LocationCell";
            LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
            if (cell ==nil) {
                cell = [[LocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.model = model;
            
            return cell;
            
        }else if(model.type == 5){
            
            static NSString *reuseIdetify = @"VoiceCell";
            VoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
            if (cell ==nil) {
                cell = [[VoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.model = model;
            
            return cell;
            
        }else{
            return nil;
        }
    }
}

//选中cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置cell选中的效果
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//接收离线消息
- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages{
    _chatTagDate = nil;
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    [self loadMoreMessagesFrom:timestamp count:[self.messages count] + [offlineMessages count] append:NO];
}

- (void)didReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages{
}

//接收在线消息
// 收到消息的回调，带有附件类型的消息可以用SDK提供的下载附件方法下载（后面会讲到）
-(void)didReceiveMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        [self addMessage:message];
        
        // 设置当前conversation的所有message为已读
        [_conversation markAllMessagesAsRead:YES];
    }
}

//传透消息
- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage{
    EMCommandMessageBody *body = (EMCommandMessageBody *)cmdMessage.messageBodies.lastObject;
    NSLog(@"收到的action是 -- %@",body.action);
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
}

//发送消息成功的回调
-(void)didSendMessage:(EMMessage *)message error:(EMError *)error
{
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[MessageModel class]])
         {
             MessageModel *model = (MessageModel*)obj;
             if ([model.messageId isEqualToString:message.messageId])
             {
                 model.message.deliveryState = message.deliveryState;
                 *stop = YES;
             }
         }
     }];
    [_chatTableView reloadData];
}

-(void)addMessage:(EMMessage *)message
{
    [_messages addObject:message];
    __weak ChatController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource addObjectsFromArray:messages];
            [weakSelf.chatTableView reloadData];
            [weakSelf.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

-(NSMutableArray *)formatMessage:(EMMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[createDate formattedTime]];
        self.chatTagDate = createDate;
    }
    
    MessageModel *model = [MessageModelManager modelWithMessage:message];
    model.nickName = model.username;
    model.headImageURL = [NSURL URLWithString:model.username];
    
    if (model) {
        [ret addObject:model];
    }
    
    return ret;
}

- (void)loadMoreMessagesFrom:(long long)timestamp count:(NSInteger)count append:(BOOL)append
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:count before:timestamp];
        if ([messages count] > 0) {
            NSInteger currentCount = 0;
            if (append)
            {
                [weakSelf.messages insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                NSArray *formated = [weakSelf formatMessages:messages];
                id model = [weakSelf.dataSource firstObject];
                if ([model isKindOfClass:[NSString class]])
                {
                    NSString *timestamp = model;
                    [formated enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                        if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                        {
                            [weakSelf.dataSource removeObjectAtIndex:0];
                            *stop = YES;
                        }
                    }];
                }
                currentCount = [weakSelf.dataSource count];
                [weakSelf.dataSource insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                
                EMMessage *latest = [weakSelf.messages lastObject];
                weakSelf.chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)latest.timestamp];
            }
            else
            {
                weakSelf.messages = [messages mutableCopy];
                weakSelf.dataSource = [[weakSelf formatMessages:messages] mutableCopy];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.chatTableView reloadData];
                
                [weakSelf.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
            
            //从数据库导入时重新下载没有下载成功的附件
            for (EMMessage *message in messages)
            {
                [weakSelf downloadMessageAttachments:message];
            }
            
            NSMutableArray *unreadMessages = [NSMutableArray array];
            for (NSInteger i = 0; i < [messages count]; i++)
            {
                EMMessage *message = messages[i];
                if ([self shouldAckMessage:message read:NO])
                {
                    [unreadMessages addObject:message];
                }
            }
            if ([unreadMessages count])
            {
                [self sendHasReadResponseForMessages:unreadMessages];
            }
        }
    });
}

- (NSArray *)formatMessages:(NSArray *)messagesArray
{
    NSMutableArray *formatArray = [[NSMutableArray alloc] init];
    if ([messagesArray count] > 0) {
        for (EMMessage *message in messagesArray) {
            NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
            if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
                [formatArray addObject:[createDate formattedTime]];
                self.chatTagDate = createDate;
            }
            
            MessageModel *model = [MessageModelManager modelWithMessage:message];
            model.nickName = model.username;
            
            model.headImageURL = [NSURL URLWithString:model.username];
            
            if (model) {
                [formatArray addObject:model];
            }
        }
    }
    
    return formatArray;
}

- (void)downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf reloadTableViewDataWithMessage:message];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"缩略图是失败的！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }
    };
    
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    if ([messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Video)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Voice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.attachmentDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载语言
            [[EaseMob sharedInstance].chatManager asyncFetchMessage:message progress:nil];
        }
    }
}

- (BOOL)shouldAckMessage:(EMMessage *)message read:(BOOL)read
{
    NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
    if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground))
    {
        return NO;
    }
    
    id<IEMMessageBody> body = [message.messageBodies firstObject];
    if (((body.messageBodyType == eMessageBodyType_Video) ||
         (body.messageBodyType == eMessageBodyType_Voice) ||
         (body.messageBodyType == eMessageBodyType_Image)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)sendHasReadResponseForMessages:(NSArray*)messages
{
    dispatch_async(_messageQueue, ^{
        for (EMMessage *message in messages)
        {
            [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
        }
    });
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak ChatController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
        {
            for (int i = 0; i < weakSelf.dataSource.count; i ++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    MessageModel *model = (MessageModel *)object;
                    if ([message.messageId isEqualToString:model.messageId]) {
                        
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
                        cellModel.nickName = cellModel.username;
                        cellModel.headImageURL = [NSURL URLWithString:cellModel.username];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.chatTableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.chatTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.chatTableView endUpdates];
                        });
                        break;
                    }
                }
            }
        }
    });
}

#pragma mark - 监听方法
//键盘的frame发生改变时调用（显示、隐藏等）
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        CGRect rr = self.CustomKeyboardView.frame;
        rr.origin.y = keyboardF.origin.y - self.CustomKeyboardView.frame.size.height;
        self.CustomKeyboardView.frame = rr;
        
        CGRect tt = self.chatTableView.frame;;
        tt.size.height = self.CustomKeyboardView.frame.origin.y-NAVH;
        self.chatTableView.frame = tt;
        
        if(self.dataSource.count > 0){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.dataSource.count-1 inSection:0];
            [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

//单击关闭键盘
- (void)CloseKeyboard{
    [self.view endEditing:YES];
    self.ExpressionKeyView.hidden = YES;
    self.otherView.hidden = YES;
    self.CustomKeyboardView.ExpressionBtn.selected = NO;
    
    CGRect rr = self.CustomKeyboardView.frame;
    rr.origin.y = HIGH-50;
    self.CustomKeyboardView.frame = rr;
    
    CGRect oo = self.otherView.frame;
    oo.origin.y = HIGH;
    self.otherView.frame = oo;
    
    CGRect tt = self.chatTableView.frame;;
    tt.size.height = self.CustomKeyboardView.frame.origin.y-NAVH;
    self.chatTableView.frame = tt;
}

#pragma -mark CustomKeyboardDelegate
//开始录音
- (void)StartVoice{
    [SoundRecord sharedInstance].delegate = self;
    [[SoundRecord sharedInstance] startRecord];
}

//完成录音
- (void)CompleteVoice{
    [[SoundRecord sharedInstance] stop];
}

//转换录音文件
- (void)SoundRecordStop:(BOOL)convertResult andPath:(NSString *)path andTime:(NSInteger)times{
    if(convertResult){
        //发送录音
        EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:path
                                                   displayName:@"audio"];
        voice.duration = times;
        [self sendAudioMessage:voice];
    }
}

//文字键盘
- (void)ChoiceWrittenWordsKeyboard{
    [self.CustomKeyboardView.textView becomeFirstResponder];
    self.ExpressionKeyView.hidden = YES;
    self.otherView.hidden = YES;
    
    CGRect tt = self.ExpressionKeyView.frame;
    tt.origin.y = HIGH;
    self.ExpressionKeyView.frame = tt;
    
    CGRect oo = self.otherView.frame;
    oo.origin.y = HIGH;
    self.otherView.frame = oo;
}

//录音键盘
- (void)ChoiceVoiceKeyboard{
    [self.CustomKeyboardView.textView resignFirstResponder];
    self.ExpressionKeyView.hidden = YES;
    self.otherView.hidden = YES;
    [self CloseKeyboard];
}

//表情键盘
- (void)ChoiceExpressionKeyboard{
    [self.CustomKeyboardView.textView resignFirstResponder];
    self.ExpressionKeyView.hidden = NO;
    self.otherView.hidden = YES;
    
    CGRect oo = self.otherView.frame;
    oo.origin.y = HIGH;
    self.otherView.frame = oo;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rr = self.CustomKeyboardView.frame;
        rr.origin.y = HIGH-265;
        self.CustomKeyboardView.frame = rr;
        
        CGRect tt = self.ExpressionKeyView.frame;
        tt.origin.y = HIGH-215;
        self.ExpressionKeyView.frame = tt;
        
        CGRect cc = self.chatTableView.frame;;
        cc.size.height = self.CustomKeyboardView.frame.origin.y-NAVH;
        self.chatTableView.frame = cc;
        
        if(self.dataSource.count > 0){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.dataSource.count-1 inSection:0];
            [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

//其他
- (void)ChoiceOtherKeyboard{
    [self.CustomKeyboardView.textView resignFirstResponder];
    self.ExpressionKeyView.hidden = YES;
    self.otherView.hidden = NO;
    
    CGRect tt = self.ExpressionKeyView.frame;
    tt.origin.y = HIGH;
    self.ExpressionKeyView.frame = tt;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rr = self.CustomKeyboardView.frame;
        rr.origin.y = HIGH-120;
        self.CustomKeyboardView.frame = rr;
        
        CGRect tt = self.otherView.frame;
        tt.origin.y = HIGH-70;
        self.otherView.frame = tt;
        
        CGRect cc = self.chatTableView.frame;
        cc.size.height = self.CustomKeyboardView.frame.origin.y-NAVH;
        self.chatTableView.frame = cc;
        
        if(self.dataSource.count > 0){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.dataSource.count-1 inSection:0];
            [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

#pragma -mark OtherDelegate
-(void)ChoiceOther:(NSInteger)type{
    if(type == 0){
        [self OpenAlbumOrCamera:0];
    }else if(type == 1){
        [self OpenAlbumOrCamera:1];
    }else if(type == 2){
        LocationViewController *locationController = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
        locationController.delegate = self;
        [self.navigationController pushViewController:locationController animated:YES];
    }
}

//重发de通知
- (void)routerEvent:(NSNotification *)notification{
    NSDictionary *dict = [notification object];
    if([[dict objectForKey:@"Type"] isEqual:@"Repeat"]){
        
        ChatCell *resendCell = [dict objectForKey:@"Cell"];
        MessageModel *messageModel = resendCell.model;
        if ((messageModel.status != eMessageDeliveryState_Failure) && (messageModel.status != eMessageDeliveryState_Pending))
        {
            return;
        }
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        [chatManager asyncResendMessage:messageModel.message progress:nil];
        NSIndexPath *indexPath = [_chatTableView indexPathForCell:resendCell];
        [_chatTableView beginUpdates];
        [_chatTableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [_chatTableView endUpdates];
        
    }else if([[dict objectForKey:@"Type"] isEqual:@"SeeLocation"]){
        double latitude = [[dict objectForKey:@"latitude"] doubleValue];
        double longitude = [[dict objectForKey:@"longitude"] doubleValue];
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(latitude,longitude);
        LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:coor];
        locationController.delegate = self;
        [self.navigationController pushViewController:locationController animated:YES];
    }
}

#pragma -mark ExpressionKeyboardDelegate
-(void)SendExpression{
    [self SendChat];
}

- (void)ChoiceExpression:(NSString *)expression{
    NSString *str = self.CustomKeyboardView.textView.text;
    self.CustomKeyboardView.textView.text = [NSString stringWithFormat:@"%@%@",str,expression];
}

- (void)SendChat{
    if(![self.CustomKeyboardView.textView.text isEqual:@""]){
        [self sendTextMessage:self.CustomKeyboardView.textView.text];
        self.CustomKeyboardView.textView.text = @"";
    }
}

#pragma -mark LocationViewDelegate 发送位置
-(void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address{
    NSDictionary *ext = nil;
    EMMessage *locationMessage = [ChatSendHelper sendLocationLatitude:latitude longitude:longitude address:address toUsername:_conversation.chatter messageType:[self messageType] requireEncryption:NO ext:ext];
    [self addMessage:locationMessage];
}

#pragma mark - send message
-(void)sendTextMessage:(NSString *)textMessage
{
    NSDictionary *ext = nil;
    EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage
                                                            toUsername:_conversation.chatter
                                                           messageType:[self messageType]
                                                     requireEncryption:NO
                                                                   ext:ext];
    [self addMessage:tempMessage];
}

-(void)sendImageMessage:(UIImage *)image
{
    NSDictionary *ext = nil;
    EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:image
                                                            toUsername:_conversation.chatter
                                                           messageType:[self messageType]
                                                     requireEncryption:NO
                                                                   ext:ext];
    [self addMessage:tempMessage];
}

-(void)sendAudioMessage:(EMChatVoice *)voice
{
    NSDictionary *ext = nil;
    EMMessage *tempMessage = [ChatSendHelper sendVoice:voice
                                            toUsername:_conversation.chatter
                                           messageType:[self messageType]
                                     requireEncryption:NO ext:ext];
    [self addMessage:tempMessage];
}

#pragma mark - action sheet delegte
- (void)OpenAlbumOrCamera:(NSInteger)type
{
    NSUInteger sourceType;
    //type=0 相册   type=1相机
    if(type){
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }else {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = sourceType;
    
    UIColor *color = [UIColor whiteColor];
    [[UINavigationBar appearance] setTintColor:color];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    imagePickerController.navigationBar.titleTextAttributes = dict;
    [imagePickerController.navigationBar setBarTintColor:RGBACOLOR(41, 46, 51, 1)];
    
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *addImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //设置image的尺寸
    CGSize imagesize = addImage.size;
    //对图片大小进行压缩--
    if(imagesize.height > 1252){
        CGSize imgsize;
        imgsize.height = 1252;
        imgsize.width = imagesize.width*1252/imagesize.height;
        addImage = [self imageWithImage:addImage scaledToSize:imgsize];
    }else if (imagesize.width > 640){
        CGSize imgsize;
        imgsize.width = 640;
        imgsize.height = imagesize.height*1252/imagesize.width;
        addImage = [self imageWithImage:addImage scaledToSize:imgsize];
    }
    
    [self sendImageMessage:addImage];
}

//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (EMMessageType)messageType
{
    EMMessageType type = eMessageTypeChat;
    if(_isChatGroup){
        type = eMessageTypeGroupChat;
    }
    return type;
}

- (ExpressionKeyboardView *)ExpressionKeyView{
    if(!_ExpressionKeyView){
        _ExpressionKeyView = [[ExpressionKeyboardView alloc] initWithFrame:CGRectMake(0, HIGH, WIDE, 215)];
        _ExpressionKeyView.delegate = self;
        [self.view addSubview:_ExpressionKeyView];
    }
    return _ExpressionKeyView;
}

- (OtherView *)otherView{
    if(!_otherView){
        _otherView = [[OtherView alloc] initWithFrame:CGRectMake(0, HIGH, WIDE, 70)];
        _otherView.delegate = self;
        [self.view addSubview:_otherView];
    }
    return _otherView;
}

- (CustomKeyboardView *)CustomKeyboardView{
    if(!_CustomKeyboardView){
        _CustomKeyboardView = [[CustomKeyboardView alloc] initWithFrame:CGRectMake(0, HIGH-50, WIDE, 50)];
        _CustomKeyboardView.delegate = self;
    }
    return _CustomKeyboardView;
}

- (void)dealloc{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

@end
