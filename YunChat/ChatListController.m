//
//  ChatListController.m
//  YunChat
//
//  Created by yiliu on 16/1/7.
//  Copyright © 2016年 mushoom. All rights reserved.
//

#import "ChatListController.h"
#import "YunChatListCell.h"
#import "GroupListCell.h"
#import "EaseMob.h"
#import "ChatController.h"
#import "AddFirendController.h"
#import "ApplyAndNoticeController.h"

@interface ChatListController ()<UITableViewDelegate,UITableViewDataSource,IChatManagerDelegate,UIAlertViewDelegate>
{
    
}
@property (nonatomic,strong) NSMutableArray      *groupArry;             //所有群
@property (nonatomic,strong) NSMutableArray      *friendsArry;           //所有好友
@property (nonatomic,strong) NSMutableArray      *blackListArry;         //黑名单
@property (nonatomic,strong) NSMutableDictionary *stateDict;             //分组状态
@property (nonatomic,strong) NSMutableArray      *addFriendsApply;       //好友请求通知

@end

@implementation ChatListController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"联系人";
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.tabBarController.navigationItem.rightBarButtonItem = rightBtn;
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
    
    [self.addFriendsApply addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"addFriendsApply"]];
    
    [self.stateDict setObject:@"0" forKey:@"1"];
    [self.stateDict setObject:@"0" forKey:@"2"];
    [self.stateDict setObject:@"0" forKey:@"3"];
    
    [self reloadDataNews];
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDE, 20)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}

- (void)addFriend{
    AddFirendController *addFriend = [[AddFirendController alloc] init];
    [self.navigationController pushViewController:addFriend animated:YES];
}

#pragma -mark  设置表视图中分区的数量
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDE, 40)];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = section;
    
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 10, 10)];
    [view addSubview:headImageView];
    
    UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, WIDE-50, 40)];
    labTitle.font = [UIFont systemFontOfSize:15];
    [view addSubview:labTitle];
    
    UILabel *llabF = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.7, WIDE, 0.3)];
    llabF.backgroundColor = RGBACOLOR(230, 230, 230, 1);
    [view addSubview:llabF];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionView:)];
    [view addGestureRecognizer:tap];
    
    if(section == 1){
        labTitle.text = @"我的好友";
    }else if(section == 2){
        labTitle.text = @"我的群组";
    }else if(section == 3){
        labTitle.text = @"黑名单";
    }
    
    NSString *key = [NSString stringWithFormat:@"%tu",section];
    NSString *state = [self.stateDict objectForKey:key];
    if([state isEqual:@"0"]){
        headImageView.image = [UIImage imageNamed:@"iconfont-yousanjiao"];
    }else{
        headImageView.image = [UIImage imageNamed:@"iconfont-sanjiao"];
    }
    
    return view;
}

#pragma -mark 设置分区头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 0.00001;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 0){
        return 20;
    }
    return 0.000001;
}

#pragma -mark 设置每个分区的单元格数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }
    
    NSString *key = [NSString stringWithFormat:@"%tu",section];
    NSString *state = [self.stateDict objectForKey:key];
    if([state isEqual:@"0"]){
        return 0;
    }else{
        if(section == 1){
            return _friendsArry.count;
        }else if(section == 2){
            return _groupArry.count;
        }else if(section == 3){
            return _blackListArry.count;
        }else{
            return 0;
        }
    }
}

#pragma -mark 设置分区的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma -mark  cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        
        static NSString *reuseIdetify = @"GroupListCell";
        GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
        if (cell ==nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reuseIdetify owner:self options:nil] lastObject];
        }
        cell.nicknameLabel.text = @"申请与通知";
        cell.headImageView.image = [UIImage imageNamed:@"newFriends"];
        cell.number.hidden = YES;
        if(self.addFriendsApply.count > 0){
            cell.number.hidden = NO;
        }
        cell.number.text = [NSString stringWithFormat:@"%tu",self.addFriendsApply.count];
        return cell;
        
    }else if(indexPath.section == 2){
        
        static NSString *reuseIdetify = @"GroupListCell";
        GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
        if (cell ==nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reuseIdetify owner:self options:nil] lastObject];
        }
        cell.number.hidden = YES;
        EMGroup *group = _groupArry[indexPath.row];
        cell.nicknameLabel.text = group.groupId;
        return cell;
        
    }else{
        
        static NSString *reuseIdetify = @"YunChatListCell";
        YunChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
        if (cell ==nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:reuseIdetify owner:self options:nil] lastObject];
        }
        if(indexPath.section == 1){
            EMBuddy *buddy = _friendsArry[indexPath.row];
            cell.nicknameLabel.text = buddy.username;
            cell.signatureLabel.text = @"夕阳无限好,只是近黄昏";
        }else if(indexPath.section == 3){
            EMBuddy *buddy = _blackListArry[indexPath.row];
            cell.nicknameLabel.text = buddy.username;
            cell.signatureLabel.text = @"维多利亚的多尔波斯克鲁里拉山.";
        }
        return cell;
        
    }
}

#pragma -mark  选中cell后，cell颜色变化
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置cell选中的效果
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *chatter;
    BOOL flag;
    if(indexPath.section == 0){
        ApplyAndNoticeController *applyandnotice = [[ApplyAndNoticeController alloc] init];
        [self.navigationController pushViewController:applyandnotice animated:YES];
        return;
    }else if(indexPath.section == 1){
        EMBuddy *buddy = _friendsArry[indexPath.row];
        chatter = buddy.username;
        flag = NO;
    }else if(indexPath.section == 2){
        EMGroup *group = _groupArry[indexPath.row];
        chatter = group.groupId;
        flag = YES;
    }else{
        return;
    }
    
    ChatController *chat = [[ChatController alloc] initWithChatter:chatter isGroup:flag];
    [self.navigationController pushViewController:chat animated:YES];
}

//当在Cell上滑动时会调用此函数
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1 || indexPath.section == 2)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

//对选中的Cell根据editingStyle进行操作
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSString *str;
        if(indexPath.section == 1)
            str = @"是否删除该好友?";
        else
            str = @"是否退出该群?";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = indexPath.section*100000 + indexPath.row;
        [alertView show];
    }
}

#pragma -mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSInteger section = alertView.tag / 100000;
        NSInteger row = alertView.tag % 100000;
        if(section == 1){
            EMBuddy *buddy = _friendsArry[row];
            EMError *error = nil;
            // 删除好友
            BOOL isSuccess = [[EaseMob sharedInstance].chatManager removeBuddy:buddy.username removeFromRemote:YES error:&error];
            if (isSuccess && !error) {
                NSLog(@"删除成功");
                [self didRemoveFirend:buddy.username];
            }
        }else if (section == 2){
            EMGroup *group = _groupArry[row];
            EMError *error = nil;
            [[EaseMob sharedInstance].chatManager leaveGroup:group.groupId error:&error];
            if (!error) {
                NSLog(@"退出群组成功");
                [self didRemoveFirend:group.groupId];
            }
        }
    }
}

- (void)sectionView:(UITapGestureRecognizer *)tap{
    NSString *key = [NSString stringWithFormat:@"%tu",tap.view.tag];
    NSString *state = [self.stateDict objectForKey:key];
    if([state isEqual:@"0"]){
        [self.stateDict setObject:@"1" forKey:key];
    }else{
        [self.stateDict setObject:@"0" forKey:key];
    }
    [_tableView reloadData];
}

//群组列表变化后的回调
- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error{
    [self reloadDataNews];
    [_tableView reloadData];
}

//添加了好友时的回调
- (void)didAcceptedByBuddy:(NSString *)username{
    [self reloadDataNews];
    [_tableView reloadData];
}

//接受好友请求成功的回调
- (void)didAcceptBuddySucceed:(NSString *)username{
    [self.addFriendsApply addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"addFriendsApply"]];
    [self reloadDataNews];
    [_tableView reloadData];
}

//登录的用户被好友从列表中删除了
-(void)didRemovedByBuddy:(NSString *)username{
    [self reloadDataNews];
    [_tableView reloadData];
}

//将好友加到黑名单完成后的回调
- (void)didBlockBuddy:(NSString *)username error:(EMError *)pError{
    [self reloadDataNews];
    [_tableView reloadData];
}

//将好友移出黑名单完成后的回调
- (void)didUnblockBuddy:(NSString *)username error:(EMError *)pError{
    [self reloadDataNews];
    [_tableView reloadData];
}

//删除好友后
- (void)didRemoveFirend:(NSString *)username{
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:username deleteMessages:YES append2Chat:NO];
    [self reloadDataNews];
    [_tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRemoveFirendGroup" object:nil];
}

//接收到好友请求通知
- (void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message{
    NSDictionary *dict = @{@"username":username,@"message":message};
    [self.addFriendsApply addObject:dict];
    [[NSUserDefaults standardUserDefaults] setObject:self.addFriendsApply forKey:@"addFriendsApply"];
    [_tableView reloadData];
}

//获取群和好友列表
- (void)reloadDataNews{
    [self.friendsArry removeAllObjects];
    [self.groupArry removeAllObjects];
    [self.blackListArry removeAllObjects];
    
    //好友列表
    EMError *error = nil;
    NSArray *buddyListB = [[EaseMob sharedInstance].chatManager fetchBuddyListWithError:&error];
    [_friendsArry addObjectsFromArray:buddyListB];
    
    //黑名单列表
    NSArray *blockedList = [[EaseMob sharedInstance].chatManager fetchBlockedList:nil];
    [_blackListArry addObjectsFromArray:blockedList];
    
    //群组列表
    NSArray *roomsList = [[EaseMob sharedInstance].chatManager groupList];
    [self.groupArry addObjectsFromArray:roomsList];
    
    //移除好友列表中加入了黑名单的人
    for (int i=0; i<blockedList.count; i++) {
        for (int y=0; y<_friendsArry.count; y++) {
            NSString *buddy1 = blockedList[i];
            EMBuddy *buddy2 = _friendsArry[y];
            if([buddy1 isEqual:buddy2.username]){
                [_friendsArry removeObjectAtIndex:y];
                break;
            }
        }
    }
}

- (NSMutableArray *)friendsArry{
    if(!_friendsArry){
        _friendsArry = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _friendsArry;
}

- (NSMutableArray *)blackListArry{
    if(!_blackListArry){
        _blackListArry = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _blackListArry;
}

- (NSMutableArray *)groupArry{
    if(!_groupArry){
        _groupArry = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _groupArry;
}

- (NSMutableDictionary *)stateDict{
    if(!_stateDict){
        _stateDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _stateDict;
}

- (NSMutableArray *)addFriendsApply{
    if(!_addFriendsApply){
        _addFriendsApply = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _addFriendsApply;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
