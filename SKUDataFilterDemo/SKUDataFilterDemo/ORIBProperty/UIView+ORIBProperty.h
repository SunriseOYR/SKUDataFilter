//
//  UIView+ORIBProperty.h
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/8.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface UIView (ORIBProperty)

//border
@property(nonatomic, assign) IBInspectable CGFloat borderWidth;
@property(nonatomic, assign) IBInspectable UIColor *borderColor;

@property(nonatomic, assign) IBInspectable CGFloat cornerRadius;

//视图的 cornerRadius 始终保持高度的一半
@property (nonatomic, assign) IBInspectable BOOL cornerCircle;

//shadow
@property(nonatomic, assign) IBInspectable CGSize shadowOffset;
@property(nonatomic, assign) IBInspectable UIColor *shadowColor;
@property(nonatomic, assign) IBInspectable CGFloat shadowOpacity;
@property(nonatomic, assign) IBInspectable CGFloat shadowRadius;


@end
