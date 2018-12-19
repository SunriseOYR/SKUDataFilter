//
//  ViewController.m
//  SKUDataFilterDemo
//
//  Created by OrangesAL on 2017/12/4.
//  Copyright © 2017年 OrangesAL. All rights reserved.
//

#import "ViewController.h"
#import "ORSKUDataFilter.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,ORSKUDataFilterDataSource>

@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet UILabel *storeL;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *skuData;;
@property (nonatomic, strong) NSMutableArray <NSIndexPath *>*selectedIndexPaths;;

@property (nonatomic, strong) ORSKUDataFilter *filter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSArray *dataSource = @[@{@"name" : @"款式",
                              @"value" : @[@"male", @"famale"]},
                            @{@"name" : @"颜色",
                              @"value" : @[@"red", @"green", @"blue"]},
                            @{@"name" : @"尺寸",
                              @"value" : @[@"XXL", @"XL", @"L", @"S", @"M"]},
                            @{@"name" : @"test",
                              @"value" : @[@"A", @"B", @"C"]},];
    _dataSource = dataSource;
    
    _selectedIndexPaths = [NSMutableArray array];
    
    _skuData = @[
                 @{@"contition":@"male,red,XL,A",
                   @"price":@"1120",
                   @"store":@"167"},
                 @{@"contition":@"male,red,M,B",
                   @"price":@"1200",
                   @"store":@"289"},
                 @{@"contition":@"male,green,L,A",
                   @"price":@"889",
                   @"store":@"300"},
                 @{@"contition":@"male,green,M,B",
                   @"price":@"991",
                   @"store":@"178"},
                 @{@"contition":@"famale,red,XL,A",
                   @"price":@"1000",
                   @"store":@"200"},
                 @{@"contition":@"famale,blue,L,B",
                   @"price":@"880",
                   @"store":@"12"},
                 @{@"contition":@"famale,blue,XXL,C",
                   @"price":@"1210",
                   @"store":@"300"},
                 @{@"contition":@"male,blue,L,C",
                   @"price":@"888",
                   @"store":@"121"},
                 @{@"contition":@"famale,green,M,C",
                   @"price":@"1288",
                   @"store":@"125"},
                 @{@"contition":@"male,blue,L,A",
                   @"price":@"1210",
                   @"store":@"123"}
                 ];
    
    _filter = [[ORSKUDataFilter alloc] initWithDataSource:self];
    
    //当数据更新的时候 需要reloadData
    [_filter reloadData];
    [self.collectionView reloadData];
    
}

#pragma mark -- collectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_dataSource[section][@"value"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
    PropertyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PropertyCell" forIndexPath:indexPath];
    NSArray *data = _dataSource[indexPath.section][@"value"];
    cell.propertyL.text = data[indexPath.row];
    
    if ([_filter.availableIndexPathsSet containsObject:indexPath]) {
        [cell setTintStyleColor:[UIColor blackColor]];
    }else {
        [cell setTintStyleColor:[UIColor lightGrayColor]];
    }
    
    if ([_filter.selectedIndexPaths containsObject:indexPath]) {
        [cell setTintStyleColor:[UIColor redColor]];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        PropertyHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerIdf" forIndexPath:indexPath];
        view.headernameL.text = _dataSource[indexPath.section][@"name"];
        return view;

    }else {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footerIdf" forIndexPath:indexPath];
        
        return view;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [_filter didSelectedPropertyWithIndexPath:indexPath];
    
    [collectionView reloadData];
    [self action_complete:nil];
}

#pragma mark -- ORSKUDataFilterDataSource

- (NSInteger)numberOfSectionsForPropertiesInFilter:(ORSKUDataFilter *)filter {
    return _dataSource.count;
}

- (NSArray *)filter:(ORSKUDataFilter *)filter propertiesInSection:(NSInteger)section {
    return _dataSource[section][@"value"];
}

- (NSInteger)numberOfConditionsInFilter:(ORSKUDataFilter *)filter {
    return _skuData.count;
}

- (NSArray *)filter:(ORSKUDataFilter *)filter conditionForRow:(NSInteger)row {
    NSString *condition = _skuData[row][@"contition"];
    return [condition componentsSeparatedByString:@","];
}

- (id)filter:(ORSKUDataFilter *)filter resultOfConditionForRow:(NSInteger)row {
    NSDictionary *dic = _skuData[row];
    return @{@"price": dic[@"price"],
             @"store": dic[@"store"]};
}

#pragma mark -- action
- (IBAction)action_complete:(id)sender {
    
    
    NSDictionary *dic = _filter.currentResult;
    
    if (dic == nil) {
        NSLog(@"请选择完整 属性");
        _priceL.text = @"￥0";
        _storeL.text = @"库存0件";
        return;
    }
    
    _priceL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
    _storeL.text = [NSString stringWithFormat:@"库存%@件",dic[@"store"]];
}



@end


@implementation PropertyCell

- (void)setTintStyleColor:(UIColor *)color {
    self.layer.borderColor = color.CGColor;
    self.propertyL.textColor = color;
}

@end

@implementation PropertyHeader

@end
