//
//  NSLayoutConstraint+ORIBProperty.h
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/9.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (ORIBProperty)

//constant
@property (nonatomic, assign) IBInspectable BOOL adaptConstant;

/*
 * 适配导航栏高度，若为YES constant将不会适配比例，而是在iphone X 上加上24pt
 */
@property (nonatomic, assign) IBInspectable BOOL adaptXTopConstant;

@end
