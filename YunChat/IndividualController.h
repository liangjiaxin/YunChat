//
//  IndividualController.h
//  YunChat
//
//  Created by yiliu on 16/1/7.
//  Copyright © 2016年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndividualController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *signOutBtn;

- (IBAction)signOut:(id)sender;

@end
