//
//  UIButton+ORIBProperty.h
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/21.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface UIButton (ORIBProperty)

//字体
@property (nonatomic, assign) IBInspectable BOOL adaptFont;

//contentEdgeInsets、titleEdgeInsets、imageEdgeInsets
@property (nonatomic, assign) IBInspectable BOOL adaptInsets;


@end
