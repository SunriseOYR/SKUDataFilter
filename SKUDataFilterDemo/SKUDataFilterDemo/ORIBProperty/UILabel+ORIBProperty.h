//
//  UILabel+ORIBProperty.h
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/8.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface UILabel (ORIBProperty)

//字体大小适配
@property (nonatomic, assign) IBInspectable BOOL adaptFont;

//下划线
@property (nonatomic, assign) IBInspectable BOOL underLine;

//中间横线
@property (nonatomic, assign) IBInspectable BOOL middleLine;



@end
