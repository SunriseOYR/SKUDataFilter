//
//  ORSKUDataFilter.h
//  SKUFilterfilter
//
//  Created by OrangesAL on 2017/12/3.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

/* Tips：
 *
 *  ----------------- warning -----------------
 *  使用注意
 1、虽然SKUDataFilter不关心具体的值，但是条件式本质是由属性组成，故代理方法filter:propertiesInSection：和方法filter:conditionForRow：数据类型应该保持一致
 2、因为SKUDataFilter关心的是属性的坐标，那么在代理方法传值的时候，代理方法filter:propertiesInSection：和方法filter:conditionForRow：各自的数据顺序要保持一致 并且两个方法的数据也要对应
 
 实际项目中，这两种情况发生的概率都非常小，因为 第一数据统一返回统一解析，格式99%都是一样。第二数据是从服务器返回，服务器的数据要进行筛选和过滤，顺序也不能弄错，一旦错误，首先服务器就会出问题
 *
 *
 *
 *  ----------------- indexPath -----------------
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
 *  ----------------- conditionIndexs -----------------
 *
 *  条件式（符合条件的属性组合-在商品中表示有库存，可售等）
 *  conditionIndex 是本filter对属性管理的关键
 *
 *  condition (r,s)
 *  使用 conditionIndex 用属性下标表示则为 (0,0)
 *
 *  conditionIndex 通过它本身的值（即为属性的Item）和下标（即为属性的section） 可以查询任何一个属性的indexPath
 
 *  ----------------- links -----------------
 *
 *  github: https://github.com/SunriseOYR/SKUDataFilter
 *  bigo: https://www.jianshu.com/p/295737e2ac77
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ORSKUDataFilter;
@class ORSKUProperty;

@protocol ORSKUDataFilterDataSource <NSObject>

@required

//属性种类个数
- (NSInteger)numberOfSectionsForPropertiesInFilter:(ORSKUDataFilter *)filter;

/*
 * 每个种类所有的的属性值
 * 这里不关心具体的值，可以是属性ID, 属性名，字典、model
 */
- (NSArray *)filter:(ORSKUDataFilter *)filter propertiesInSection:(NSInteger)section;

//满足条件 的 个数
- (NSInteger)numberOfConditionsInFilter:(ORSKUDataFilter *)filter;

/*
 * 对应的条件式
 * 这里条件式的属性值，需要和propertiesInSection里面的数据类型保持一致
 */
- (NSArray *)filter:(ORSKUDataFilter *)filter conditionForRow:(NSInteger)row;

//条件式 对应的 结果数据（库存、价格等）
- (id)filter:(ORSKUDataFilter *)filter resultOfConditionForRow:(NSInteger)row;

@end

@interface ORSKUDataFilter : NSObject

@property (nonatomic, assign) id<ORSKUDataFilterDataSource> dataSource;

//当前 选中的属性indexPath
@property (nonatomic, strong, readonly) NSArray <NSIndexPath *> *selectedIndexPaths;
//当前 可选的属性indexPath
@property (nonatomic, strong, readonly) NSSet <NSIndexPath *> *availableIndexPathsSet;
//当前 结果
@property (nonatomic, strong, readonly) id  currentResult;


//init
- (instancetype)initWithDataSource:(id<ORSKUDataFilterDataSource>)dataSource;

//选中 属性的时候 调用
- (void)didSelectedPropertyWithIndexPath:(NSIndexPath *)indexPath;

//重新加载数据
- (void)reloadData;


@end


@interface ORSKUCondition :NSObject

@property (nonatomic, strong) NSArray<ORSKUProperty *> *properties;

@property (nonatomic, strong, readonly) NSArray<NSNumber *> *conditionIndexs;

@property (nonatomic, strong) id result;

@end

@interface ORSKUProperty :NSObject

@property (nonatomic, copy, readonly) NSIndexPath * indexPath;
@property (nonatomic, copy, readonly) id value;

- (instancetype)initWithValue:(id)value indexPath:(NSIndexPath *)indexPath;

@end

