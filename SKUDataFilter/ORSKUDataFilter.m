//
//  ORSKUDataFilter.m
//  SKUFilterfilter
//
//  Created by OrangesAL on 2017/12/3.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "ORSKUDataFilter.h"

@interface ORSKUDataFilter() {
    ORSKUCondition *_defaultSku;
}

@property (nonatomic, strong) NSSet <ORSKUCondition *> *conditions;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *selectedIndexPaths;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *availableIndexPathsSet;

//全可用的
@property (nonatomic, strong) NSSet <NSIndexPath *> *allAvailableIndexPaths;

@property (nonatomic, strong) id  currentResult;

@end

@implementation ORSKUDataFilter

- (instancetype)initWithDataSource:(id<ORSKUDataFilterDataSource>)dataSource
{
    self = [super init];
    if (self) {
        _dataSource = dataSource;
        _selectedIndexPaths = [NSMutableSet set];
        [self initPropertiesSkuListData];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selectedIndexPaths = [NSMutableSet set];
    }
    return self;
}

- (void)reloadData {
    [_selectedIndexPaths removeAllObjects];
    _defaultSku = nil;
    [self initPropertiesSkuListData];
    [self updateCurrentResult];
}

#pragma mark -- public method
//选中某个属性
- (void)didSelectedPropertyWithIndexPath:(NSIndexPath *)indexPath {
    
    if (![_availableIndexPathsSet containsObject:indexPath]) {
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
    
    [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        if (indexPath.section == obj.section) {
            lastIndexPath = obj;
        }
    }];
    
    if (!lastIndexPath) {
        //添加新属性
        [_selectedIndexPaths addObject:indexPath];
        [_availableIndexPathsSet intersectSet:[self availableIndexPathsFromSelctedIndexPath:indexPath sectedIndexPaths:_selectedIndexPaths]];
        [self updateCurrentResult];
        return;
    }
    
    if (lastIndexPath.item != indexPath.item) {
        //切换属性
        [_selectedIndexPaths addObject:indexPath];
        [_selectedIndexPaths removeObject:lastIndexPath];
        [self updateAvailableIndexPaths];
        [self updateCurrentResult];
    }
    
}


#pragma mark -- private method

//获取初始数据
- (void)initPropertiesSkuListData {
    
    NSMutableSet *modelSet = [NSMutableSet set];

    for (int i = 0; i < [_dataSource numberOfConditionsInFilter:self]; i ++) {
        
        ORSKUCondition *model = [ORSKUCondition new];
        NSArray * conditions = [_dataSource filter:self conditionForRow:i];
        
        if (![self checkConformToSkuConditions:conditions]) {
            NSLog(@"第 %d 个 condition 不完整 \n %@", i, conditions);
            continue;
        }
        
        model.properties = [self propertiesWithConditionRawData:conditions];
        model.result = [_dataSource filter:self resultOfConditionForRow:i];
        
        if (self.selectedIndexPaths.count == 0 && _needDefaultValue && !_defaultSku) {
            _defaultSku = model;
        }
        
        [modelSet addObject:model];
    }
    _conditions = [modelSet copy];
    
    [self getAllAvailableIndexPaths];
    
    if (_defaultSku) {
        [_defaultSku.properties enumerateObjectsUsingBlock:^(ORSKUProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self didSelectedPropertyWithIndexPath:obj.indexPath];
        }];
    }
}

//检查数据是否正确
- (BOOL)checkConformToSkuConditions:(NSArray *)conditions {
    if (conditions.count != [_dataSource numberOfSectionsForPropertiesInFilter:self]) {
        return NO;
    }
    
    __block BOOL  flag = YES;
    [conditions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *properties = [_dataSource filter:self propertiesInSection:idx];
        if (![properties containsObject:obj]) {
            flag = NO;
            *stop = YES;
        }
    }];
    return flag;
}

//获取属性
- (NSArray<ORSKUProperty *> *)propertiesWithConditionRawData:(NSArray *)data {
    
    NSMutableArray *array = [NSMutableArray array];
    [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:[self propertyOfValue:obj inSection:idx]];
    }];
    
    return array;
}

- (ORSKUProperty *)propertyOfValue:(id)value inSection:(NSInteger)section {
    
    NSArray *properties = [_dataSource filter:self propertiesInSection:section];
    
    NSString *str = [NSString stringWithFormat:@"Properties for %ld dosen‘t exist %@", (long)section, value];
    NSAssert([properties containsObject:value], str);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[properties indexOfObject:value] inSection:section];
    
    return [[ORSKUProperty alloc] initWithValue:value indexPath:indexPath];
}


//获取初始可选的所有IndexPath
- (NSMutableSet<NSIndexPath *> *)getAllAvailableIndexPaths {

    NSMutableSet *set = [NSMutableSet set];
    [_conditions enumerateObjectsUsingBlock:^(ORSKUCondition * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj.conditionIndexs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
            [set addObject:[NSIndexPath indexPathForItem:obj1.integerValue inSection:idx1]];
        }];
    }];
    
    _availableIndexPathsSet = set;
    
    _allAvailableIndexPaths = [set copy];
    
    return set;
}

//选中某个属性时 根据已选中的系列属性 获取可选的IndexPath
- (NSMutableSet<NSIndexPath *> *)availableIndexPathsFromSelctedIndexPath:(NSIndexPath *)selectedIndexPath sectedIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    
    NSMutableSet *set = [NSMutableSet set];
    [_conditions enumerateObjectsUsingBlock:^(ORSKUCondition * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.conditionIndexs objectAtIndex:selectedIndexPath.section].integerValue == selectedIndexPath.item) {
            
            [obj.properties enumerateObjectsUsingBlock:^(ORSKUProperty * _Nonnull property, NSUInteger idx2, BOOL * _Nonnull stop1) {
                                
                //从condition中添加种类不同的属性时，需要根据已选中的属性过滤
                //过滤方式为 condition要么包含已选中 要么和已选中属性是同级
                if (property.indexPath.section != selectedIndexPath.section) {
                    
                    __block BOOL flag = YES;
                    
                    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj1, BOOL * _Nonnull stop) {
                        
                        flag = (([obj.conditionIndexs[obj1.section] integerValue] == obj1.row) || (obj1.section == property.indexPath.section)) && flag;
                    }];
                    
                    if (flag) {
                        [set addObject:property.indexPath];
                    }
                    
                }else {
                    [set addObject:property.indexPath];
                }
            }];
        }
    }];
    
    //合并本行数据
    [_allAvailableIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.section == selectedIndexPath.section) {
            [set addObject:obj];
        }
    }];
    
    return set;
}

//当前可用的
- (void)updateAvailableIndexPaths {
    
    if (_selectedIndexPaths.count == 0) {
        
        _availableIndexPathsSet = [_allAvailableIndexPaths mutableCopy];
        return ;
    }
    
    __block NSMutableSet *set = [NSMutableSet set];
    
    NSMutableSet *seleted = [NSMutableSet setWithCapacity:_selectedIndexPaths.count];
    
    [_selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        
        [seleted addObject:obj];
        
        NSMutableSet *tempSet = nil;
        
        tempSet = [self availableIndexPathsFromSelctedIndexPath:obj sectedIndexPaths:seleted];
        
        if (set.count == 0) {
            set = [tempSet mutableCopy];
        }else {
            [set intersectSet:tempSet];
        }
        
    }];
    
    _availableIndexPathsSet = set;

    
}

// 当前结果
- (void)updateCurrentResult {
    
    if (_selectedIndexPaths.count != [_dataSource numberOfSectionsForPropertiesInFilter:self]) {
        _currentResult = nil;
        return;
    }
    [_conditions enumerateObjectsUsingBlock:^(ORSKUCondition * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.conditionIndexPaths isEqualToSet:self.selectedIndexPaths]) {
            self.currentResult = obj.result;
            *stop = YES;
        }
    }];
}

- (NSArray *)currentAvailableResutls {
    
    if (_selectedIndexPaths.count == [_dataSource numberOfSectionsForPropertiesInFilter:self]) {
        return @[_currentResult];
    }
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:_conditions.count];
    [_conditions enumerateObjectsUsingBlock:^(ORSKUCondition * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self.selectedIndexPaths isSubsetOfSet:obj.conditionIndexPaths]) {
            [results addObject:obj.result];
        }
    }];
    return results;
}

#pragma mark -- setter
- (void)setDataSource:(id<ORSKUDataFilterDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setNeedDefaultValue:(BOOL)needDefaultValue {
    
    _needDefaultValue = needDefaultValue;
    
    if (_selectedIndexPaths.count > 0 || !needDefaultValue) {
        return;
    }
    
    [self reloadData];
}

@end

@implementation ORSKUCondition

- (void)setProperties:(NSArray<ORSKUProperty *> *)properties {
    
    _properties = properties;
    NSMutableArray *conditionIndexs = [NSMutableArray arrayWithCapacity:properties.count];
    NSMutableSet *conditionIndexPaths = [NSMutableSet setWithCapacity:properties.count];
    
    [properties enumerateObjectsUsingBlock:^(ORSKUProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [conditionIndexs addObject:@(obj.indexPath.item)];
        [conditionIndexPaths addObject:obj.indexPath];
    }];
    
    _conditionIndexs = conditionIndexs.copy;
    _conditionIndexPaths = conditionIndexPaths.copy;
}

@end

@implementation ORSKUProperty

- (instancetype)initWithValue:(id)value indexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    if (self) {
        _value = value;
        _indexPath = indexPath;
    }
    return self;
}

@end



