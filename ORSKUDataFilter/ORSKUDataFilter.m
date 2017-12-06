//
//  ORSKUDataFilter.m
//  SKUFilterfilter
//
//  Created by OrangesAL on 2017/12/3.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "ORSKUDataFilter.h"

@interface ORSKUDataFilter()

@property (nonatomic, strong) NSSet <ORSkuModel *> *skuModels;

@property (nonatomic, strong) NSArray <NSIndexPath *> *allAvailableIndexPaths;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *> *selectedIndexPaths;

@property (nonatomic, strong) NSArray <NSIndexPath *> *availableIndexPaths;

@property (nonatomic, strong) id  currentResult;

@end

@implementation ORSKUDataFilter

- (instancetype)initWithDataSource:(id<ORSKUDataFilterDataSource>)dataSource
{
    self = [super init];
    if (self) {
        _dataSource = dataSource;
        _selectedIndexPaths = [NSMutableArray array];
        [self initPropertiesSkuListData];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selectedIndexPaths = [NSMutableArray array];
    }
    return self;
}

#pragma mark -- public method
//选中某个属性
- (void)didSelectedPropertyWithIndexPath:(NSIndexPath *)indexPath {
    
    if (![[self availableIndexPaths] containsObject:indexPath]) {
        //不可选
        return;
    }
    
    if (indexPath.section > [_dataSource numberOfSectionsForPropertiesInFilter:self] || indexPath.item >= [[_dataSource filter:self propertiesInSection:indexPath.section] count]) {
        //越界
        NSLog(@"indexPath is out of range");
        return;
    }
    
    if ([_selectedIndexPaths containsObject:indexPath]) {
        //已被选
        [_selectedIndexPaths removeObject:indexPath];
        
        [self updateAvailableIndexPaths];
        [self updateCurrentResult];
        return;
    }
    
    __block NSIndexPath *lastIndexPath = nil;
    
    [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (indexPath.section == obj.section) {
            lastIndexPath = obj;
        }
    }];
    
    if (lastIndexPath.item != indexPath.item || !lastIndexPath) {
        [_selectedIndexPaths addObject:indexPath];
        [_selectedIndexPaths removeObject:lastIndexPath];
    }
    
    [self updateAvailableIndexPaths];
    [self updateCurrentResult];
}

- (BOOL)isAvailableWithPropertyIndexPath:(NSIndexPath *)indexPath {
    
    __block BOOL isAvailable = NO;
    
    [_skuModels enumerateObjectsUsingBlock:^(ORSkuModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.conditionIndexs objectAtIndex:indexPath.section].integerValue == indexPath.row) {
            isAvailable = YES;
        }
    }];;
    
    return isAvailable;
}


#pragma mark -- private method

//获取初始数据
- (void)initPropertiesSkuListData {
    
    NSMutableSet *modelSet = [NSMutableSet set];

    for (int i = 0; i < [_dataSource numberOfConditionsInFilter:self]; i ++) {
        ORSkuModel *model = [ORSkuModel new];
        NSArray<NSString *> * conditions = [_dataSource filter:self conditionForRow:i];
        model.conditions = conditions;
        model.conditionIndexs = [self indexsForProperties:conditions];
        model.result = [_dataSource filter:self resultOfConditionForRow:i];
        
        [modelSet addObject:model];
    }
    _skuModels = [modelSet copy];
    
    _allAvailableIndexPaths = [self getAllAvailableIndexPaths].allObjects;
    _availableIndexPaths = _allAvailableIndexPaths;
}

//获取条件式 对应 的数据
- (id)skuResultWithConditionIndexs:(NSArray<NSNumber *> *)conditionIndexs {
    
    __block id result = nil;
    
    [_skuModels enumerateObjectsUsingBlock:^(ORSkuModel * _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj.conditionIndexs isEqual:conditionIndexs]) {
            result = obj.result;
            *stop = YES;
        }
    }];
    
    return result;
}

//根据 下标 条件式 获取 对应 的数据
- (id)skuResultWithConditions:(NSArray<NSString *> *)conditions {
    
    __block id result = nil;
    
    [_skuModels enumerateObjectsUsingBlock:^(ORSkuModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.conditions isEqual:conditions]) {
            result = obj.result;
            *stop = YES;
        }
    }];
    
    return result;
}


//获取某个属性的下标
- (NSInteger)indexForProperty:(NSString *)property inSection:(NSInteger)section {
    
    NSArray *result = [_dataSource filter:self propertiesInSection:section];
    
    NSString *str = [NSString stringWithFormat:@"Properties for %ld dosen‘t exist %@", (long)section, property];
    NSAssert([result containsObject:property], str);
    
    return [result indexOfObject:property];
}

//获取一组属性的下标
- (NSArray<NSNumber *> *)indexsForProperties:(NSArray<NSString *> *)properties {
    
    NSMutableArray *array = [NSMutableArray array];
    [properties enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:@([self indexForProperty:obj inSection:idx])];
    }];
    return array;
}

//获取初始可选的所有IndexPath
- (NSMutableSet<NSIndexPath *> *)getAllAvailableIndexPaths {

    NSMutableSet *set = [NSMutableSet set];
    [_skuModels enumerateObjectsUsingBlock:^(ORSkuModel * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.conditionIndexs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
            [set addObject:[NSIndexPath indexPathForItem:obj1.integerValue inSection:idx1]];
        }];
        
    }];
    
    return set;
}

//选中某个属性时 根据已选中的系列属性 获取可选的IndexPath
- (NSMutableSet<NSIndexPath *> *)availableIndexPathsFromSelctedIndexPath:(NSIndexPath *)selectedIndexPath sectedIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    
    NSMutableSet *set = [NSMutableSet set];
    [_skuModels enumerateObjectsUsingBlock:^(ORSkuModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.conditionIndexs objectAtIndex:selectedIndexPath.section].integerValue == selectedIndexPath.item) {
            
            [obj.conditionIndexs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop1) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:obj2.integerValue inSection:idx2];
                
                //从condition中添加种类不同的属性时，需要根据已选中的属性过滤
                //过滤方式为 condition要么包含已选中 要么和已选中属性是同级
                if (indexPath.section != selectedIndexPath.section) {
                    
                    __block BOOL flag = YES;
                    
                    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        flag = (([obj.conditionIndexs[obj1.section] integerValue] == obj1.row) || (obj1.section == indexPath.section)) && flag;
                    }];
                    
                    if (flag) {
                        [set addObject:indexPath];
                    }
                }else {
                    [set addObject:indexPath];
                }
            }];
            
        }
    }];
    
    //合并本行数据
    [_allAvailableIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.section == selectedIndexPath.section) {
            [set addObject:obj];
        }
    }];
    
    return set;
}

//当前可用的
- (void)updateAvailableIndexPaths {
    
    if (_selectedIndexPaths.count == 0) {
        _availableIndexPaths = _allAvailableIndexPaths;
        return ;
    }
    
    __block NSMutableSet *set = [NSMutableSet set];
    
    NSMutableArray *seleted = [NSMutableArray array];
    
    [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [seleted addObject:obj];
        
        NSMutableSet *tempSet = nil;
        
        tempSet = [self availableIndexPathsFromSelctedIndexPath:obj sectedIndexPaths:seleted];
        
        if (set.count == 0) {
            set = [tempSet mutableCopy];
        }else {
            [set intersectSet:tempSet];
        }
        
    }];
    
    _availableIndexPaths = set.allObjects;
}

// 当前结果
- (void)updateCurrentResult {
    
    if (_selectedIndexPaths.count != [_dataSource numberOfSectionsForPropertiesInFilter:self]) {
        _currentResult = nil;
        return;
    }
    NSMutableArray *conditions = [NSMutableArray array];
    
    for (int i = 0; i < [_dataSource numberOfSectionsForPropertiesInFilter:self]; i ++) {
        [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj.section == i) {
                [conditions addObject:@(obj.row)];
            }
        }];
        
    }
    _currentResult = [self skuResultWithConditionIndexs:[conditions copy]];
}


#pragma mark -- setter
- (void)setDataSource:(id<ORSKUDataFilterDataSource>)dataSource {
    _dataSource = dataSource;
    [self initPropertiesSkuListData];
}

@end

@implementation ORSkuModel

@end




