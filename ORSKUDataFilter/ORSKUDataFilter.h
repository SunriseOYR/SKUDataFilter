//
//  ORSKUDataFilter.h
//  SKUFilterfilter
//
//  Created by OrangesAL on 2017/12/3.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* Tips：
 *
 *  ----------------- conditionIndex -----------------
 *
 *  indexPath记录属性的位置坐标
 *  表示为 第section 种属性类下面的 第item个 属性 （从0计数)
 *
 *  例：
 *
 *  颜色: r g
 *  尺寸: s m l
 *
 *  属性m 表示为 secton : 1, item : 1
 *
 *  ----------------- conditionIndex -----------------
 *
 *  条件式（符合条件的属性组合-在商品中表示有库存，可售等）
 *  conditionIndex 是本filter对属性管理的关键
 *
 *  condition (r,s)
 *  使用 conditionIndex 用属性下标表示则为 (0,0)
 *
 *  conditionIndex 通过它本身的值（即为属性的Item）和下标（即为属性的section） 可以查询任何一个属性的indexPath
 */

@class ORSKUDataFilter;
@class ORSKUProperty;

@protocol ORSKUDataFilterDataSource <NSObject>

@required

//属性种类个数
- (NSInteger)numberOfSectionsForPropertiesInFilter:(ORSKUDataFilter *)filter;

//每行所有的的属性值
- (NSArray *)filter:(ORSKUDataFilter *)filter propertiesInSection:(NSInteger)section;

//满足条件 的 个数
- (NSInteger)numberOfConditionsInFilter:(ORSKUDataFilter *)filter;

//对应的条件式
- (NSArray *)filter:(ORSKUDataFilter *)filter conditionForRow:(NSInteger)row;

//条件对应的 其他数据 
- (id)filter:(ORSKUDataFilter *)filter resultOfConditionForRow:(NSInteger)row;

@end

@interface ORSKUDataFilter : NSObject

@property (nonatomic, assign) id<ORSKUDataFilterDataSource> dataSource;

//当前 选中的属性indexPath
@property (nonatomic, strong, readonly) NSArray <NSIndexPath *> *selectedIndexPaths;
//当前 可选的属性indexPath
@property (nonatomic, strong, readonly) NSArray <NSIndexPath *> *availableIndexPaths;
//当前 结果
@property (nonatomic, strong, readonly) id  currentResult;


//init
- (instancetype)initWithDataSource:(id<ORSKUDataFilterDataSource>)dataSource;

//选中 属性的时候 调用
- (void)didSelectedPropertyWithIndexPath:(NSIndexPath *)indexPath;

//判断某个属性是否可选
- (BOOL)isAvailableWithPropertyIndexPath:(NSIndexPath *)indexPath;

@end


@interface ORSKUCondition :NSObject

@property (nonatomic, strong) NSArray<ORSKUProperty *> *properties;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *conditionIndexs;

@property (nonatomic, copy) id result;

@end

@interface ORSKUProperty :NSObject

@property (nonatomic, copy) NSIndexPath * indexPath;
@property (nonatomic, copy) id value;

- (instancetype)initWithValue:(id)value indexPath:(NSIndexPath *)indexPath;

@end

