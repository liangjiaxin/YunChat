//
//  YunChatController.m
//  YunChat
//
//  Created by yiliu on 15/10/20.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "YunChatController.h"
#import "YunChatListCell.h"
#import "ChatController.h"
#import "AppDelegate.h"

#import "EaseMob.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "NSDate+Category.h"

@interface YunChatController ()<UITableViewDataSource,UITableViewDelegate,IChatManagerDelegate>{
    
}

@property (nonatomic,strong) NSMutableArray *dataLoadDataSource;   //当前用户的所有会话列表
@property (nonatomic,strong) NSMutableArray      *groupArry;             //所有群
@property (nonatomic,strong) NSMutableArray      *friendsArry;           //所有好友

@end

@implementation YunChatController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"消息";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (id)init{
    self = [super init];
    if(self){
        //注册一个监听对象到监听列表中,监听环信SDK事件
        [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //删除了好友
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveFirendGroup:) name:@"didRemoveFirendGroup" object:nil];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.tabBarController.navigationItem.backBarButtonItem = backItem;
    
    self.view.backgroundColor = RGBACOLOR(246, 246, 246, 1);
    
    //设置tableview分割线长度(ios7/ios8)
    if ([_YunChatListTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_YunChatListTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([_YunChatListTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_YunChatListTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    _YunChatListTableView.delegate = self;
    _YunChatListTableView.dataSource = self;
    _YunChatListTableView.tableFooterView = [[UIView alloc] init];
    
}

#pragma -mark UITableViewDelegate,UITableViewDataSource
//设置每个分区的单元格数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataLoadDataSource.count;
}

//设置分区的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdetify = @"YunChatListCell";
    YunChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (cell ==nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reuseIdetify owner:self options:nil] lastObject];
        //设置tableview分割线长度(ios7/ios8)
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    
    cell.messageNumbLabel.hidden = YES;
    
    //聊天的会话对象
    EMConversation *conversation = _dataLoadDataSource[indexPath.row];
    
    if (conversation.conversationType == eConversationTypeChat) {
        
        //单聊
        EMBuddy *buddyt;
        for (EMBuddy *buddy in _friendsArry) {
            if ([buddy.username isEqualToString:conversation.chatter]) {
                buddyt = buddy;
                break;
            }
        }
        
        cell.headImageView.image = [UIImage imageNamed:@"head2"];
        cell.nicknameLabel.text = buddyt.username;
        cell.signatureLabel.text = [self subTitleMessageByConversation:conversation];
        cell.timeLabel.text = [self lastMessageTimeByConversation:conversation];
        NSInteger num = [self unreadMessageCountByConversation:conversation];
        if(num>0){
            if(num > 99){
                cell.messageNumbLabel.text = [NSString stringWithFormat:@"99+"];
                cell.messageNumbLabel.frame = CGRectMake(35, 5, 30, 20);
            }else{
                cell.messageNumbLabel.text = [NSString stringWithFormat:@"%tu",num];
                cell.messageNumbLabel.frame = CGRectMake(40, 5, 20, 20);
            }
            cell.messageNumbLabel.hidden = NO;
        }
        
    }else if(conversation.conversationType == eConversationTypeGroupChat) {
        
        //群聊
        EMGroup *groupt;
        for (EMGroup *group in _groupArry) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                groupt = group;
                break;
            }
        }
        
        cell.headImageView.image = [UIImage imageNamed:@"head2"];
        cell.nicknameLabel.text = [NSString stringWithFormat:@"%@【群】",groupt.groupSubject];
        cell.signatureLabel.text = [NSString stringWithFormat:@"%@:%@",[self subNameMessageByConversation:conversation],[self subTitleMessageByConversation:conversation]];
        cell.timeLabel.text = [self lastMessageTimeByConversation:conversation];
        NSInteger num = [self unreadMessageCountByConversation:conversation];
        if(num>0){
            if(num > 99){
                cell.messageNumbLabel.text = [NSString stringWithFormat:@"99+"];
                cell.messageNumbLabel.frame = CGRectMake(35, 5, 30, 20);
            }else{
                cell.messageNumbLabel.text = [NSString stringWithFormat:@"%tu",num];
                cell.messageNumbLabel.frame = CGRectMake(40, 5, 20, 20);
            }
            cell.messageNumbLabel.hidden = NO;
        }
        
    }
    
    return cell;
}

//选中cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置cell选中的效果
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //聊天的会话对象
    EMConversation *conversation = _dataLoadDataSource[indexPath.row];
    if (conversation.conversationType == eConversationTypeChat) {
        
        //单聊
        for (EMBuddy *buddy in _friendsArry) {
            if ([buddy.username isEqualToString:conversation.chatter]) {
                ChatController *chat = [[ChatController alloc] initWithChatter:buddy.username isGroup:NO];
                [self.navigationController pushViewController:chat animated:YES];
                break;
            }
        }
        
    }else if(conversation.conversationType == eConversationTypeGroupChat) {
        
        //群聊
        for (EMGroup *group in _groupArry) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                ChatController *chat = [[ChatController alloc] initWithChatter:group.groupId isGroup:YES];
                [self.navigationController pushViewController:chat animated:YES];
                break;
            }
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = @"[图片]";
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                ret = @"[音频]";
            } break;
            case eMessageBodyType_Location: {
                ret = @"[位置]";
            } break;
            case eMessageBodyType_Video: {
                ret = @"[视频]";
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}

//获取最后一条消息的发送者
- (NSString *)subNameMessageByConversation:(EMConversation *)conversation{
    EMMessage *lastMessage = [conversation latestMessage];
    NSDictionary *ext = lastMessage.ext;   //(环信：扩展消息）
    if(ext){
        return [NSString stringWithFormat:@"%@:",[ext objectForKey:@"name"]];
    }else{
        return lastMessage.from;
    }
}

////获取消息的发送者的头像
//- (NSString *)subHeadImageMessageByConversation:(EMConversation *)conversation{
//    EMMessage *lastMessage = [conversation latestMessage];
//    NSDictionary *ext = lastMessage.ext;   //环信：扩展消息）
//    if(ext){
//        return [ext objectForKey:@"headImage"];
//    }
//    return @"";
//}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    return  ret;
}

//当前登陆用户的会话对象列表
- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    
    return ret;
}

//获取群和好友列表
- (void)reloadDataNews{
    [self.friendsArry removeAllObjects];
    [self.groupArry removeAllObjects];
    
    //好友列表
    EMError *error = nil;
    NSArray *buddyListB = [[EaseMob sharedInstance].chatManager fetchBuddyListWithError:&error];
    NSLog(@"%@",error);
    NSMutableArray *buddyList = [[NSMutableArray alloc] initWithArray:buddyListB];
    
    if(buddyList.count > 0){
        [self.friendsArry addObjectsFromArray:buddyList];
    }
    
    //群组列表
    NSArray *roomsList = [[EaseMob sharedInstance].chatManager groupList];
    if(roomsList.count > 0){
        [self.groupArry addObjectsFromArray:roomsList];
    }
}

//未读消息改变时
-(void)didUnreadMessagesCountChanged{
    [self reloadDataNews];
    _dataLoadDataSource = [self loadDataSource];
    [_YunChatListTableView reloadData];
}

//群组列表变化后的回调
- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error{
    [self reloadDataNews];
    _dataLoadDataSource = [self loadDataSource];
    [_YunChatListTableView reloadData];
}

//添加了好友时的回调
- (void)didAcceptedByBuddy:(NSString *)username{
    [self reloadDataNews];
    _dataLoadDataSource = [self loadDataSource];
    [_YunChatListTableView reloadData];
}

//接受好友请求成功的回调
- (void)didAcceptBuddySucceed:(NSString *)username{
    [self reloadDataNews];
    _dataLoadDataSource = [self loadDataSource];
    [_YunChatListTableView reloadData];
}

//登录的用户被好友从列表中删除了
- (void)didRemovedByBuddy:(NSString *)username{
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:username deleteMessages:YES append2Chat:NO];
    
    [self reloadDataNews];
    _dataLoadDataSource = [self loadDataSource];
    [_YunChatListTableView reloadData];
}

//将好友加到黑名单完成后的回调
- (void)didBlockBuddy:(NSString *)username error:(EMError *)pError{
    [self reloadDataNews];
    _dataLoadDataSource = [self loadDataSource];
    [_YunChatListTableView reloadData];
}

//将好友移出黑名单完成后的回调
- (void)didUnblockBuddy:(NSString *)username error:(EMError *)pError{
    [self reloadDataNews];
    _dataLoadDataSource = [self loadDataSource];
    [_YunChatListTableView reloadData];
}

////收到消息时(可以播放提示音什么的)
//- (void)didReceiveMessage:(EMMessage *)message{
//}

// 发送消息后的回调
- (void)didSendMessage:(EMMessage *)message error:(EMError *)error{
    _dataLoadDataSource = [self loadDataSource];
    [_YunChatListTableView reloadData];
}

//删除了好友
- (void)didRemoveFirendGroup:(NSNotification*)notification{
    [self reloadDataNews];
    _dataLoadDataSource = [self loadDataSource];
    [_YunChatListTableView reloadData];
}

- (NSMutableArray *)friendsArry{
    if(!_friendsArry){
        _friendsArry = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _friendsArry;
}

- (NSMutableArray *)groupArry{
    if(!_groupArry){
        _groupArry = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _groupArry;
}

- (NSMutableArray *)dataLoadDataSource{
    if(!_dataLoadDataSource){
        _dataLoadDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _dataLoadDataSource;
}

//用户将要进行自动登录操作的回调
- (void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    NSLog(@"dddd");
}

// 结束自动登录回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
    //获取群组列表
    [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
}

@end
