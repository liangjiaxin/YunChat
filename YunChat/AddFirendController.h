//
//  AddFirendController.h
//  YunChat
//
//  Created by yiliu on 16/1/8.
//  Copyright © 2016年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFirendController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *contentField;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
- (IBAction)addFirend:(id)sender;


@end
