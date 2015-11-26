//
//  Auxiliary.h
//  YunChat
//
//  Created by yiliu on 15/10/21.
//  Copyright (c) 2015年 mushoom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface Auxiliary : NSObject

/**
 *自适应高度宽度
 */
+ (CGSize)CalculationHeightWidth:(NSString *)str andSize:(float)fot andCGSize:(CGSize)size;

@end
