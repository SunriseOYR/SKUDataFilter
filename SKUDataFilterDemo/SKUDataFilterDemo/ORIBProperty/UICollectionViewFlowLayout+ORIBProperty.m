//
//  UICollectionViewFlowLayout+ORIBProperty.m
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/13.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "UICollectionViewFlowLayout+ORIBProperty.h"
#import "ORIBProperty.h"

static const NSString *numberItemsForRowKey = @"numberItemsForRowKey";
static const NSString *adaptSizeKey = @"adaptSizeKey";

@implementation UICollectionViewFlowLayout (ORIBProperty)

- (void)setAdaptSize:(BOOL)adaptSize {
    

    if (adaptSize == true) {
        
        if (self.adaptSize == true && self.numberItemsForRow > 0) {
            [self itemSizeAdapt];
        }else {
            self.minimumLineSpacing = IB_HP(self.minimumLineSpacing);
            self.minimumInteritemSpacing = IB_HP(self.minimumInteritemSpacing);
            
            self.headerReferenceSize = CGSizeMake(IB_HP(self.headerReferenceSize.width), IB_HP(self.headerReferenceSize.height));
            
            self.footerReferenceSize = CGSizeMake(IB_HP(self.footerReferenceSize.width), IB_HP(self.footerReferenceSize.height));
            
            self.sectionInset = insetsAdaptWithInsets(self.sectionInset);
            
            [self itemSizeAdapt];
        }
        
    }
    
    objc_setAssociatedObject(self, &adaptSizeKey, @(adaptSize), OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (BOOL)adaptSize {
    return [objc_getAssociatedObject(self, &adaptSizeKey) boolValue];
}

- (void)setNumberItemsForRow:(NSInteger)numberItemsForRow {
    
    objc_setAssociatedObject(self, &numberItemsForRowKey, @(numberItemsForRow), OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.adaptSize = true;

}

- (NSInteger)numberItemsForRow {
    return [objc_getAssociatedObject(self, &numberItemsForRowKey) integerValue];
}

- (void)itemSizeAdapt {
    
    if (self.numberItemsForRow == 0) {
        
        self.itemSize = CGSizeMake(IB_HP(self.itemSize.width), IB_HP(self.itemSize.height));
    }else {
        CGFloat proportion = self.itemSize.width / self.itemSize.height ;
        
        CGFloat width = (IB_HP(self.collectionView.bounds.size.width) - self.sectionInset.left - self.sectionInset.right -(self.numberItemsForRow - 1) * self.minimumInteritemSpacing) / self.numberItemsForRow - 0.06;
        
        self.itemSize = CGSizeMake(width, width / proportion);
    }
    
}

@end
