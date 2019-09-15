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
    @IBOutlet weak var collectionView: UICollectionView!

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
        filter.needDefaultValue = true
        collectionView.reloadData()
        self.updateResult()
    }
    
    func updateResult() {
        
        guard let dic = filter.currentResult as? [String : String] else {
            self.priceL.text = "￥0";
            self.storeL.text = "库存0件";
            print("属性不完整")
            return
        }
        
        priceL.text = "￥" + (dic["price"] ?? "0")
        storeL.text = "库存" + (dic["store"] ?? "0") + "件"
    }
    
    @IBAction func action_complete(_ sender: Any) {
        self.updateResult()
    }
    
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let value = dataSource[section]["value"] as! Array<Any>
        return value.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PropertyCell",
            for: indexPath
            ) as! PropertyCell
        
        let value = dataSource[indexPath.section]["value"] as! Array<String>
        cell.propertyL.text = value[indexPath.row]
        
        if filter.selectedIndexPaths.contains(indexPath) {
            cell.tintStyleColor = UIColor.red
        }else if filter.availableIndexPathsSet.contains(indexPath) {
            cell.tintStyleColor = UIColor.black
        }else {
            cell.tintStyleColor = UIColor.lightGray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerIdf",
                for: indexPath
                ) as! PropertyHeader
            
            let title = dataSource[indexPath.section]["name"] as! String
            view.headernameL.text = title;
            return view
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "footerIdf",
            for: indexPath
            )
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filter.selectedProperty(at: indexPath)
        collectionView.reloadData()
        self.updateResult()
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
        return skuData[row]
    }
    
    
}

class PropertyCell: UICollectionViewCell {
    
    @IBOutlet weak var propertyL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
    }
    
    var tintStyleColor : UIColor? {
        set {
            self.layer.borderColor = newValue?.cgColor
            self.propertyL.textColor = newValue
        }
        
        get {
            return self.propertyL.textColor
        }
    }
    
}

class PropertyHeader: UICollectionReusableView {
    
    @IBOutlet weak var headernameL: UILabel!
}
