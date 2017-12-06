//
//  UITextView+ORIBProperty.m
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/13.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "UITextView+ORIBProperty.h"
#import "ORIBProperty.h"

@implementation UITextView (ORIBProperty)

- (void)setAdaptFont:(BOOL)adaptFont {
    
    if (adaptFont == true) {
        self.font = fontAdaptWithFont(self.font);
    }
}

- (BOOL)adaptFont {
    return false;
}


@end

