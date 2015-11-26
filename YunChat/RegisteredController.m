//
//  RegisteredController.m
//  YunChat
//
//  Created by yiliu on 15/11/5.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "RegisteredController.h"
#import "EaseMob.h"
#import "AppDelegate.h"
#import "MyNavigationController.h"

#import "YunChatController.h"
#import "ChatListController.h"
#import "IndividualController.h"

@interface RegisteredController ()<EMChatManagerDelegate>

@end

@implementation RegisteredController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapKeyBorad)];
    [self.view addGestureRecognizer:tap];
    
    _loginBtn.layer.cornerRadius = 4;
    _loginBtn.layer.masksToBounds = YES;
    _loginBtn.backgroundColor = RGBACOLOR(16, 131, 155, 1);
    
    _registeredBtn.layer.cornerRadius = 4;
    _registeredBtn.layer.masksToBounds = YES;
    _registeredBtn.backgroundColor = RGBACOLOR(16, 131, 155, 1);
    
}

- (void)TapKeyBorad{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)RegisteredBtn:(id)sender {
    
    if([_nameTextField.text isEqual:@""] || [_passwordTextField.text isEqual:@""]){
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"账号和密码不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }
    
    [self showHudInView:self.view hint:@"注册中..."];
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:_nameTextField.text password:_passwordTextField.text withCompletion:^(NSString *username, NSString *password, EMError *error) {
        [self hideHud];
        if (error) {
            NSString *str = [NSString stringWithFormat:@"%@",error];
            [[[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }else{
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"注册成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }
    } onQueue:nil];
    
}

- (IBAction)LoginBtn:(id)sender {
    
    if([_nameTextField.text isEqual:@""] || [_passwordTextField.text isEqual:@""]){
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"账号和密码不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }
    
    [self showHudInView:self.view hint:@"登陆中..."];
    if(![[EaseMob sharedInstance].chatManager isLoggedIn]){
        //异步登陆账号
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:_nameTextField.text password:_passwordTextField.text completion:^(NSDictionary *loginInfo, EMError *error) {
            [self hideHud];
            if(error){
                NSLog(@"%@",error);
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            }else{
                //设置是否自动登录
                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                //获取群组列表
                [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
                //获取好友列表
                [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
                //从数据库获取信息
                [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                //跳转页面
                [self Login];
            }
            
        }onQueue:nil];
    }else{
        [self hideHud];
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"已经登录成功了" delegate:nil cancelButtonTitle:@"好吧，忘了" otherButtonTitles: nil] show];
        [self Login];
    }
    
}

//登陆成功
- (void)Login{
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"ISLOGIN"];
    
    AppDelegate *apd = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    YunChatController *YunChat = [[YunChatController alloc] init];
    
    ChatListController *chatList = [[ChatListController alloc] init];
    
    IndividualController *individual = [[IndividualController alloc] init];
    
    apd.tabbar.viewControllers = @[YunChat,chatList,individual];
    
    MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:apd.tabbar];
    
    apd.window.rootViewController = nav;
}

@end
