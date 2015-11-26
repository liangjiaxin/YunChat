//
//  MyTextField.m
//  meitu
//
//  Created by yiliu on 15/5/15.
//  Copyright (c) 2015年 meitu. All rights reserved.
//

#import "MyTabBarController.h"

@interface MyTabBarController (){
    NSArray *aryImage;    //未选中时的图片
    NSArray *arySelImage; //选中时的图片
    NSArray *aryTitle;    //所有标题
    int num;   //按钮的数量
}

//设置之前选中的按钮
@property (nonatomic,strong) UIButton *selectedBtn;

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加数据
    num = 3;
    arySelImage = [[NSArray alloc] initWithObjects:@"iconfont-xiaoxi",@"iconfont-haoyou-1",@"iconfont-my", nil];
    aryImage = [[NSArray alloc] initWithObjects:@"iconfont-iconfontxiaoxiweixuanzhong",@"iconfont-wodehaoyou-2",@"iconfont-gerenzhongxin-5", nil];
    
    //删除现有的tabBar
    [self.tabBar removeFromSuperview];  //移除TabBarController自带的下部的条
    
    //添加自己的视图
    _myView = [[UIImageView alloc] init];
    _myView.userInteractionEnabled = YES;
    _myView.frame = self.tabBar.frame;
    //_myView.image = [UIImage imageNamed:@""];
    _myView.backgroundColor = RGBACOLOR(16, 131, 155, 1);
    [self.view addSubview:_myView];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDE, 0.3)];
    lab.backgroundColor = RGBACOLOR(200, 200, 200, 1);
    [_myView addSubview:lab];
    
    for (int i = 0; i < num; i++) {
        
        //添加按钮
        UIButton *btn = [[UIButton alloc] init];
        CGFloat x = i * _myView.frame.size.width / num;
        btn.frame = CGRectMake(x, 0, _myView.frame.size.width / num, _myView.frame.size.height);
        [_myView addSubview:btn];
        
        //添加图标
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((btn.bounds.size.width-33)/2, 8, 33, 33)];
        imageView.tag = 200+i;
        imageView.image = [UIImage imageNamed:aryImage[i]];
        [btn addSubview:imageView];
        
        btn.tag = 1000+i;//设置按钮的标记, 方便来索引当前的按钮,并跳转到相应的视图
        
        //带参数的监听方法记得加"冒号"
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        //设置刚进入时,第一个按钮为选中状态
        if (0 == i) {
            imageView.image = [UIImage imageNamed:arySelImage[i]];
            btn.selected = YES;
            self.selectedBtn = btn;  //设置该按钮为选中的按钮
        }  
    }
}

- (void)setSelectButton:(NSInteger)tag{
    UIButton *but = (UIButton *)[self.view viewWithTag:tag+1000];
    [self clickBtn:but];
}

//自定义TabBar的按钮点击事件
- (void)clickBtn:(UIButton *)button {
    
    //设置所有按钮的状态
    for (int i=0; i<num; i++) {
        UIImageView *imgView = (UIImageView *)[self.view viewWithTag:200+i];
        if(i == button.tag-1000){
            imgView.image = [UIImage imageNamed:arySelImage[i]];
        }else{
            imgView.image = [UIImage imageNamed:aryImage[i]];
        }
    }
    
    //1.先将之前选中的按钮设置为未选中
    self.selectedBtn.selected = NO;
    //2.再将当前按钮设置为选中
    button.selected = YES;
    //3.最后把当前按钮赋值为之前选中的按钮
    self.selectedBtn = button;
    //4.跳转到相应的视图控制器. (通过selectIndex参数来设置选中了那个控制器)
    self.selectedIndex = button.tag-1000;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
