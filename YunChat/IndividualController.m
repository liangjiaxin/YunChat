//
//  IndividualController.m
//  YunChat
//
//  Created by yiliu on 16/1/7.
//  Copyright © 2016年 mushoom. All rights reserved.
//

#import "IndividualController.h"
#import "IndividualCell.h"
#import "Auxiliary.h"
#import "EaseMob.h"
#import "RegisteredController.h"
#import "MyNavigationController.h"
#import "AppDelegate.h"

@interface IndividualController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *titleArry;
    NSArray *contentArry;
}

@end

@implementation IndividualController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"个人中心";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleArry = @[@"昵         称",@"性         别",@"年         龄",@"城         市",@"个 性 签 名"];
    contentArry = @[@"一朵梅花开枝头",@"女",@"22",@"杭州",@"何时仗尔看南雪, 我与梅花两白头."];
    
    _headImageView.layer.cornerRadius = 50;
    _headImageView.layer.masksToBounds = YES;
    
    _signOutBtn.layer.cornerRadius = 4;
    _signOutBtn.layer.masksToBounds = YES;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}

#pragma -mark 设置每个分区的单元格数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

#pragma -mark 设置分区的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma -mark  cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *reuseIdetify = @"IndividualCell";
    IndividualCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (cell ==nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reuseIdetify owner:self options:nil] lastObject];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = titleArry[indexPath.row];
    cell.contentLabel.text = contentArry[indexPath.row];
    
    return cell;
}

#pragma -mark  选中cell后，cell颜色变化
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//退出
- (IBAction)signOut:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"是否退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES];
        RegisteredController *Registered = [[RegisteredController alloc] init];
        MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:Registered];
        AppDelegate *apd = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        apd.window.rootViewController = nav;
    }
}

@end
