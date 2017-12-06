//
//  UITextField+ORIBProperty.m
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/13.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "UITextField+ORIBProperty.h"
#import "ORIBProperty.h"

@implementation UITextField (ORIBProperty)

- (void)setAdaptFont:(BOOL)adaptFont {
    
    if (adaptFont == true) {
        self.font = fontAdaptWithFont(self.font);
    }
}

- (BOOL)adaptFont {
    return false;
}


@end
