//
//  AppDelegate.m
//  YunChat
//
//  Created by yiliu on 15/10/20.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "AppDelegate.h"
#import "EaseMob.h"
#import "IQKeyboardManager.h"
#import "MyNavigationController.h"

#import "RegisteredController.h"
#import "YunChatController.h"
#import "ChatListController.h"
#import "IndividualController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = NO;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = NO;
    
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"easemob-demo#chatdemoui" apnsCertName:@"chatdemoui"];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[EaseMob sharedInstance].chatManager enableAutoLogin];
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
    
    _tabbar = [[MyTabBarController alloc] init];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ISLOGIN"]){
        
        YunChatController *YunChat = [[YunChatController alloc] init];
        
        ChatListController *chatList = [[ChatListController alloc] init];
        
        IndividualController *individual = [[IndividualController alloc] init];
        
        _tabbar.viewControllers = @[YunChat,chatList,individual];
        
        MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:_tabbar];
        
        self.window.rootViewController = nav;
        
        
    }else{
        
        RegisteredController *Registered = [[RegisteredController alloc] init];
        
        MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:Registered];
        
        self.window.rootViewController = nav;
        
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

@end
