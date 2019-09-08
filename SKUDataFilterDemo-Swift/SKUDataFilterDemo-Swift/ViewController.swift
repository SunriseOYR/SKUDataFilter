//
//  ViewController.swift
//  SKUDataFilterDemo-Swift
//
//  Created by 欧阳荣 on 2019/9/8.
//  Copyright © 2019 OrangesAL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var priceL: UILabel!
    @IBOutlet weak var storeL: UILabel!
    
    private let dataSource = [
    
        ["name" : "款式",
         "value" : ["male", "famale"]],
        
        ["name" : "颜色",
         "value" : ["red", "green", "blue"]],
        
        ["name" : "尺寸",
         "value" : ["XXL", "XL", "L", "S", "M"]],
        
        ["name" : "test",
         "value" : ["A", "B", "C"]]
    ]
    
    private let skuData : [[String : String]] = [
        
        ["condition" : "male,red,XL,A",
         "price" : "1120",
         "store" : "167"],
        
        ["condition" : "male,red,M,B",
         "price" : "1200",
         "store" : "289"],
        
        ["condition" : "male,green,L,A",
         "price" : "889",
         "store" : "300"],
        
        ["condition" : "male,green,M,B",
         "price" : "991",
         "store" : "178"],
        
        ["condition" : "famale,red,XL,A",
         "price" : "1000",
         "store" : "200"],
        
        ["condition" : "famale,blue,L,B",
         "price" : "880",
         "store" : "12"],
        
        ["condition" : "famale,blue,XXL,C",
         "price" : "1210",
         "store" : "300"],
        
        ["condition" : "male,blue,L,C",
         "price" : "888",
         "store" : "121"],
        
        ["condition" : "famale,green,M,C",
         "price" : "1288",
         "store" : "125"],
        
        ["condition" : "male,blue,L,A",
         "price" : "1210",
         "store" : "123"]
    ]
    
    private lazy var filter = ORSKUDataFilter(dataSource: self);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func action_complete(_ sender: Any) {
        
    }
    
}


extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
            ) as! CollectionViewCell
        
        let title = list[indexPath.section].items[indexPath.item].title
        cell.set(text: title)
        cell.set(enabled: filter.available.contains(indexPath))
        cell.set(selected: filter.selecteds.contains(indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
            ) as! CollectionReusableView
        
        let title = list[indexPath.section].title
        view.set(text: title)
        return view
    }
}



extension ViewController : ORSKUDataFilterDataSource {
    
    func numberOfSectionsForProperties(filter: ORSKUDataFilter) -> Int {
        return dataSource.count
    }
    
    func properties(filter: ORSKUDataFilter, in section: Int) -> [AnyHashable] {
        return dataSource[section]["value"] as! [AnyHashable]
    }
    
    func numberOfConditions(filter: ORSKUDataFilter) -> Int {
        return skuData.count
    }
    
    func condition(filter: ORSKUDataFilter, at row: Int) -> [AnyHashable] {
        
        let skuString = skuData[row]["condition"]
        return skuString!.components(separatedBy: ",")
    }
    
    func resultOfCondition(filter: ORSKUDataFilter, at row: Int) -> Any? {
        return skuData[row]["price"]
    }
    
    
}
