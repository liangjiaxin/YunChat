//
//  RegisteredController.h
//  YunChat
//
//  Created by yiliu on 15/11/5.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisteredController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *registeredBtn;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (IBAction)RegisteredBtn:(id)sender;

- (IBAction)LoginBtn:(id)sender;

@end
