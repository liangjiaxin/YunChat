//
//  ApplyAndNoticeController.m
//  YunChat
//
//  Created by yiliu on 16/1/8.
//  Copyright © 2016年 mushoom. All rights reserved.
//

#import "ApplyAndNoticeController.h"
#import "YunChatListCell.h"
#import "EaseMob.h"

@interface ApplyAndNoticeController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic,strong) NSMutableArray *dataArry;

@end

@implementation ApplyAndNoticeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"申请与通知";
    
    [self.dataArry addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"addFriendsApply"]];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
}

#pragma -mark UITableViewDelegate,UITableViewDataSource
//设置每个分区的单元格数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArry.count;
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
    }
    
    NSDictionary *dict = _dataArry[indexPath.row];
    cell.nicknameLabel.text = dict[@"username"];
    cell.signatureLabel.text = dict[@"message"];
    return cell;
}

//选中cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否同意加好友？" delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    alertView.tag = indexPath.row;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSDictionary *dict = _dataArry[alertView.tag];
    NSString *username = dict[@"username"];
    if(buttonIndex == 0){
        EMError *error = nil;
        BOOL isSuccess = [[EaseMob sharedInstance].chatManager rejectBuddyRequest:username reason:@"" error:&error];
        if (isSuccess && !error) {
            NSLog(@"发送拒绝成功");
            [_dataArry removeObjectAtIndex:alertView.tag];
            [[NSUserDefaults standardUserDefaults] setObject:_dataArry forKey:@"addFriendsApply"];
            [_tableView reloadData];
        }
    }else{
        EMError *error = nil;
        BOOL isSuccess = [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:&error];
        if (isSuccess && !error) {
            NSLog(@"发送同意成功");
            [_dataArry removeObjectAtIndex:alertView.tag];
            [[NSUserDefaults standardUserDefaults] setObject:_dataArry forKey:@"addFriendsApply"];
            [_tableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)dataArry{
    if(!_dataArry){
        _dataArry = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _dataArry;
}

@end
