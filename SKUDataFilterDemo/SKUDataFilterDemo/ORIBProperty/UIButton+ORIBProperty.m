//
//  UIButton+ORIBProperty.m
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/21.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "UIButton+ORIBProperty.h"
#import "ORIBProperty.h"

@implementation UIButton (ORIBProperty)

- (void)setAdaptInsets:(BOOL)adaptInsets {
    
    if (adaptInsets == true) {
        
        self.contentEdgeInsets = insetsAdaptWithInsets(self.contentEdgeInsets);
        self.titleEdgeInsets = insetsAdaptWithInsets(self.titleEdgeInsets);
        self.imageEdgeInsets = insetsAdaptWithInsets(self.imageEdgeInsets);
    }
}

- (BOOL)adaptInsets {
    return false;
}

- (void)setAdaptFont:(BOOL)adaptFont {
    
    if (adaptFont == true) {
        self.titleLabel.adaptFont = true;
    }
}

- (BOOL)adaptFont {
    return false;
}


@end
