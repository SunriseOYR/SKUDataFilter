# SKUFilterManager
SKU 商品规格组合算法 

![003.gif](http://upload-images.jianshu.io/upload_images/5192751-68d22cd9e80f8e08.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

[博客详解](http://www.jianshu.com/p/295737e2ac77)

SKUDataFilter 使用NSIndexPath记录每个属性的坐标。表示为 **第section 种属性类下面的 第item个 属性 （从0计数)**
条件式下标(conditionIndexs)中记录的属性indexPath的 item


       // 判断属性是否存在于条件式中
       conditionIndexs[indexPath.section] == indexPath.row
  
**数据通配**  
 conditionIndexs 和indexPath的结合 为SKUDataFilter 不仅算法上取得了优势，同时也在 数据通配 上起了莫大的作用

不同的后台，不同的需求，返回的数据结构都不一样。

然而SKUDataFilter真正关心的是属性的坐标，而不是属性本身的的值，那么不管你从后台获取的数据结构是怎样的，也不管你是如何解析的。当然，你也不需要去关心坐标和条件式下标等等乱七八糟的。你需要做的只是把对应的数据放入对应的代理方法里面去就行了，不管数据是model，属性ID、字典还是其他的。

**使用说明**

SKUDataFilter最终直接反映的是属性的indexPath, 如果你的属性在UI显示上使用UICollectionView实现，那么indexPath是一一对应的，如果用的循环创建，找到对应的行和列即可。

1、初始化Filter 并设置代理  

     - (instancetype)initWithDataSource:(id<ORSKUDataFilterDataSource>)dataSource;


2、通过代理方法 ，将数据传给Filter

以下方法都必需实现，分别告诉Filter，属性种类个数、每个种类的所有属性（数组），条件式个数、每个条件式包含的所有属性、以及每个条件式对应的结果（可以参考本文案例）

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
       * 这里条件式的属性值，需要和filter:propertiesInSection里面的数据 类型保持一致
       */
      - (NSArray *)filter:(ORSKUDataFilter *)filter conditionForRow:(NSInteger)row;

      //条件式 对应的 结果数据（库存、价格等）
      - (id)filter:(ORSKUDataFilter *)filter resultOfConditionForRow:(NSInteger)row;

3、点击某个属性的时候 把对应属性的indexPath传给Filter

    - (void)didSelectedPropertyWithIndexPath:(NSIndexPath *)indexPath;

4、查询结果(与代理方法resultOfConditionForRow：对应)-条件不完整会返回nil

     @property (nonatomic, strong, readonly) id  currentResult;

5、可选属性集合列表、已选属性坐标列表  

    //当前 选中的属性indexPath
    @property (nonatomic, strong, readonly) NSArray <NSIndexPath *> *selectedIndexPaths;
    //当前 可选的属性indexPath
    @property (nonatomic, strong, readonly) NSArray <NSIndexPath *> *availableIndexPaths;

**使用注意** 

1、虽然SKUDataFilter不关心具体的值，但是条件式本质是由属性组成，故代理方法filter:propertiesInSection：和方法filter:conditionForRow：数据类型应该保持一致  
2、因为SKUDataFilter关心的是属性的坐标，那么在代理方法传值的时候，代理方法filter:propertiesInSection：和方法filter:conditionForRow：各自的数据顺序要保持一致 并且两个方法的数据也要对应 

如本文案例条件式是从上往下（M,G,X），传过去的 属性值 也都是从左到右（F、M）-各自保持一致。 同时
条件式为从上到下，那么propertiesInSection： 也应该是从上到下,先是（F、M）最后是（L、X、S） 

实际项目中，这两种情况发生的概率都非常小，因为 第一数据统一返回统一解析，格式99%都是一样。第二数据是从服务器返回，服务器的数据要进行筛选和过滤，顺序也不能弄错，一旦错误，首先服务器就会出问题
