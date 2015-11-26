//
//  ChatController.h
//  YunChat
//
//  Created by yiliu on 15/10/21.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;


- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;

    
@end
