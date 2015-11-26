//
//  AddFirendController.m
//  YunChat
//
//  Created by yiliu on 16/1/8.
//  Copyright © 2016年 mushoom. All rights reserved.
//

#import "AddFirendController.h"
#import "EaseMob.h"

@interface AddFirendController ()

@end

@implementation AddFirendController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加好友";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addFirend:(id)sender {
    if([[EaseMob sharedInstance].chatManager addBuddy:_contentField.text message:@"" error:nil]){
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"发送好友请求成功！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"发送好友请求失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

@end
