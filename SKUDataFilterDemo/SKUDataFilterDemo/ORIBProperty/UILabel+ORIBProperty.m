//
//  UILabel+ORIBProperty.m
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/8.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "UILabel+ORIBProperty.h"
#import "ORIBProperty.h"

@implementation UILabel (ORIBProperty)

- (void)setAdaptFont:(BOOL)adaptFont {
    
    if (adaptFont == true) {
        self.font = fontAdaptWithFont(self.font);
    }
}

- (BOOL)adaptFont {
    return false;
}

- (void)setUnderLine:(BOOL)underLine {
    
    if (underLine == true) {
        
        [self setAttributedWirhAttributeName:NSUnderlineStyleAttributeName];
        
        __weak typeof (self) weakSelf = self;

        [self aspect_hookSelector:@selector(setText:) withOptions:AspectPositionAfter usingBlock:^(){
            
            [weakSelf setAttributedWirhAttributeName:NSUnderlineStyleAttributeName];
        } error:nil];
        
    }
}

- (BOOL)underLine {
    return false;
}

- (void)setMiddleLine:(BOOL)middleLine {
    
    if (middleLine == true) {
        
        [self setAttributedWirhAttributeName:NSStrikethroughStyleAttributeName];
        
        __weak typeof (self) weakSelf = self;

        [self aspect_hookSelector:@selector(setText:) withOptions:AspectPositionAfter usingBlock:^(){
            
            [weakSelf setAttributedWirhAttributeName:NSStrikethroughStyleAttributeName];
        } error:nil];
        
    }
}

- (BOOL)middleLine {
    return false;
}

- (void)setAttributedWirhAttributeName:(NSString *)key {
    
    NSMutableAttributedString *aText = [[NSMutableAttributedString alloc] initWithString:self.text];
    [aText addAttribute:key value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, aText.length)];
    self.attributedText = aText;
}

@end
