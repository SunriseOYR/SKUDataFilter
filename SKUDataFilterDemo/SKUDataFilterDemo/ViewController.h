//
//  ViewController.h
//  SKUDataFilterDemo
//
//  Created by OrangesAL on 2017/12/4.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end

@interface PropertyCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *propertyL;

- (void)setTintStyleColor:(UIColor *)color;

@end

@interface PropertyHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *headernameL;

@end
