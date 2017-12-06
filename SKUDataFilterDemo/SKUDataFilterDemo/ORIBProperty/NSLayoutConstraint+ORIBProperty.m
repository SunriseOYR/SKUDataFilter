//
//  NSLayoutConstraint+ORIBProperty.m
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/9.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "NSLayoutConstraint+ORIBProperty.h"
#import "ORIBProperty.h"

static NSString *adaptXTopConstantKey = @"adaptXTopConstantKey";

@implementation NSLayoutConstraint (ORIBProperty)

- (void)setAdaptConstant:(BOOL)adaptConstant {
    
    if (adaptConstant == true && self.adaptXTopConstant == false) {
        self.constant = IB_HP(self.constant);
    }
}

- (BOOL)adaptConstant {
    return false;
}

- (void)setAdaptXTopConstant:(BOOL)adaptXTopConstant {
    
    objc_setAssociatedObject(self, &adaptXTopConstantKey, @(adaptXTopConstant), OBJC_ASSOCIATION_ASSIGN);
    
    if (adaptXTopConstant == true) {
        //iPhone X
        if ([UIScreen mainScreen].bounds.size.height > 800) {
            self.constant += 24;
        }
    }
}

- (BOOL)adaptXTopConstant {
    return [objc_getAssociatedObject(self, &adaptXTopConstantKey) boolValue];
}



@end
