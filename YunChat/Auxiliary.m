//
//  Auxiliary.m
//  YunChat
//
//  Created by yiliu on 15/10/21.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import "Auxiliary.h"
#import <UIKit/UIKit.h>

@implementation Auxiliary

#pragma mark--自适应高度宽度
+ (CGSize)CalculationHeightWidth:(NSString *)str andSize:(float)fot andCGSize:(CGSize)size{
    
    if([str isEqual:@""]){
        return CGSizeMake(0, 0);
    }
    
    UIFont * tfont = [UIFont systemFontOfSize:fot];
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    
    return [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
}

@end
