//
//  UICollectionViewFlowLayout+ORIBProperty.h
//  BaidiLuxury
//
//  Created by OrangesAL on 2017/11/13.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionViewFlowLayout (ORIBProperty) 

/* itemSize、minimumLineSpacing、minimumInteritemSpacing、headerReferenceSize、footerReferenceSize、sectionInset
 */
@property (nonatomic, assign) IBInspectable BOOL adaptSize;

//每行显示的item个数 为自动设置 adaptSize 为true
@property (nonatomic, assign) IBInspectable NSInteger numberItemsForRow;

@end
