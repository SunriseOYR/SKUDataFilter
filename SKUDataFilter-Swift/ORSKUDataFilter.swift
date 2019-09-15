//
//  ORSKUDataFilter.swift
//  SKUDataFilter-Swift
//
//  Created by 欧阳荣 on 2019/7/22.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

protocol ORSKUDataFilterDataSource: NSObjectProtocol {
    
    //属性种类个数
    func numberOfSectionsForProperties(filter: ORSKUDataFilter) -> Int
    
    /*
     * 每个种类所有的的属性值
     * 这里不关心具体的值，可以是属性ID, 属性名，字典、model
     */
    func properties(filter: ORSKUDataFilter, in section: Int) -> [AnyHashable]
    
    //满足条件(条件式) 的 个数
    func numberOfConditions(filter: ORSKUDataFilter) -> Int
    
    /*
     * 对应的条件式
     * 这里条件式的属性值，需要和propertiesInSection里面的数据类型保持一致
     */
    func condition(filter: ORSKUDataFilter, at row: Int) -> [AnyHashable]
    
    //条件式 对应的 结果数据（库存、价格等）
    func resultOfCondition(filter: ORSKUDataFilter, at row: Int) -> Any?
}

class ORSKUDataFilter {
    
    weak var dataSource: ORSKUDataFilterDataSource? {
        didSet { reloadData() }
    }
    
    //是否需要默认选中第一组SKU
    var needDefaultValue:Bool? {
        didSet {
            guard selectedIndexPaths.count == 0 && needDefaultValue == true else {
                return
            }
            reloadData()
        }
    }

    //当前 选中的 属性indexPath
    private(set) var selectedIndexPaths: Set<IndexPath> = []
    //当前 可选的属性 indexPath
    private(set) var availableIndexPathsSet: Set<IndexPath> = []
    //当前 结果
    private(set) var currentResult: Any?
    
    private var allAvailableIndexPaths: Set<IndexPath> = []
    private var conditions: Set<ORSKUCondition> = []
    
    
    
    init(dataSource: ORSKUDataFilterDataSource) {
        self.dataSource = dataSource
        reloadData()
    }
    
    /// 刷新数据
    func reloadData() {
        guard let dataSource = dataSource else {
            // 清理
            selectedIndexPaths = []
            availableIndexPathsSet = []
            currentResult = nil
            allAvailableIndexPaths = []
            conditions = []
            return
        }
        
        // 清空
        selectedIndexPaths = []
        availableIndexPathsSet = []
        
        
        var defaultSkuIndexPath:Set<IndexPath>?
        var temps = Set<ORSKUCondition>()
        (0 ..< dataSource.numberOfConditions(filter: self)).forEach {
            
            let conditions = dataSource.condition(filter: self, at: $0)
            
            var tempIndexPaths = Set<IndexPath>()
            let arrtibutes: [ORSKUProperty] = conditions.enumerated().compactMap {
                guard
                    dataSource.numberOfSectionsForProperties(filter: self) > $0,
                    let index = dataSource.properties(filter: self, in: $0).firstIndex(of: $1) else {
                        
                        print("第 \($0) 个 condition 不完整 \n \(conditions)")
                        return nil
                }
                let indexPath = IndexPath(item: index, section: $0)
                tempIndexPaths.insert(indexPath)
                return ORSKUProperty(indexPath, $1)
            }
            
            if arrtibutes.count == conditions.count {
                
                if (temps.count == 0 && needDefaultValue == true) {
                    defaultSkuIndexPath = tempIndexPaths;
                }
                
                let condition = ORSKUCondition(
                    properties: arrtibutes,
                    indexs: arrtibutes.map { $0.indexPath.item },
                    result: dataSource.resultOfCondition(filter: self, at: $0),
                    indexPaths: tempIndexPaths
                )
                temps.insert(condition)
            }
        }
        conditions = temps
        
        // 可选集合
        availableIndexPathsSet = Set<IndexPath>(temps.flatMap {
            $0.indexs.enumerated().map {
                IndexPath(item: $1, section: $0)
            }
        })
        
        allAvailableIndexPaths = availableIndexPathsSet
        
        if defaultSkuIndexPath != nil {
            defaultSkuIndexPath?.forEach { (indexPath) in
                selectedProperty(at: indexPath)
            }
        }
        
    }
    
    /// 选择
    ///
    /// - Parameter indexPath: 位置
    func selectedProperty(at indexPath: IndexPath) {
        guard availableIndexPathsSet.contains(indexPath) else {
            // 不可选
            return
        }
        guard
            let section = dataSource?.numberOfSectionsForProperties(filter: self),
            let item = dataSource?.properties(filter: self, in: indexPath.section).count,
            indexPath.section < section,
            indexPath.item < item else {
                // 越界
                return
        }
        guard !selectedIndexPaths.contains(indexPath) else {
            // 已选
            selectedIndexPaths.remove(indexPath)
            updateAvailable()
            updateResult()
            return
        }
        

        if let brather = selectedIndexPaths.filter({ $0.section == indexPath.section }).first {
            // 移除兄弟属性
            selectedIndexPaths.insert(indexPath)
            selectedIndexPaths.remove(brather)
            updateAvailable()
            updateResult()
            
        } else {
            // 新增
            selectedIndexPaths.insert(indexPath)
            availableIndexPathsSet.formIntersection(availableIndexPathsSet(indexPath, with: selectedIndexPaths))
            updateResult()
        }
    }
}

extension ORSKUDataFilter {
    /// 更新可选集合
    private func updateAvailable() {
        if selectedIndexPaths.isEmpty {
            availableIndexPathsSet = allAvailableIndexPaths
            return
        }
        
        var temps: Set<IndexPath> = []
        var set: Set<IndexPath> = []
        selectedIndexPaths.forEach {
            temps.insert($0)
            let availableIndexPathsSet = self.availableIndexPathsSet($0, with: temps)
            set = set.isEmpty ? availableIndexPathsSet : set.intersection(availableIndexPathsSet)
        }
        availableIndexPathsSet = set
    }
    
    /// 获取可选集合
    private func availableIndexPathsSet(_ selected: IndexPath, with selectedIndexPaths: Set<IndexPath>) -> Set<IndexPath> {
        var temps = Set<IndexPath>()
        
        conditions.forEach { (condition) in
            guard
                condition.indexs.count > selected.section,
                condition.indexs[selected.section] == selected.item else {
                    return
            }
            
            condition.properties.forEach { (property) in
                if property.indexPath.section == selected.section {
                    temps.insert(property.indexPath)
                    
                } else {
                    let flag = !selectedIndexPaths.contains {
                        (condition.indexs.count > $0.section &&
                            condition.indexs[$0.section] != $0.item) &&
                            $0.section != property.indexPath.section
                    }
                    
                    if flag { temps.insert(property.indexPath) }
                }
            }
        }
        allAvailableIndexPaths
            .filter { $0.section == selected.section }
            .forEach { temps.insert($0) }
        return temps
    }
    
    /// 更新结果
    private func updateResult() {
        guard selectedIndexPaths.count == dataSource?.numberOfSectionsForProperties(filter: self) else {
            currentResult = nil
            return
        }
        
       currentResult = conditions.filter({ $0.indexPaths == selectedIndexPaths }).first?.result
    }
}

extension ORSKUDataFilter {
    
    struct ORSKUCondition: Hashable, Equatable {
        let properties: [ORSKUProperty]
        let indexs: [Int]
        let result: Any?
        let indexPaths: Set<IndexPath>
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(properties)
            hasher.combine(indexs)
            hasher.combine(indexPaths)
        }
        
        static func == (lhs: ORSKUDataFilter.ORSKUCondition,
                        rhs: ORSKUDataFilter.ORSKUCondition) -> Bool {
            return lhs.properties == rhs.properties
                && lhs.indexs == rhs.indexs
        }
    }
    
    struct ORSKUProperty: Hashable, Equatable {
        let indexPath: IndexPath
        let value: AnyHashable
        
        init(_ indexPath: IndexPath, _ value: AnyHashable) {
            self.indexPath = indexPath
            self.value = value
        }
    }
}
