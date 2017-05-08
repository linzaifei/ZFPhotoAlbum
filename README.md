# ZFPhotoAlbum
/*!
* 排显示数目 默认 3 (3 - 5)
*/

@property(assign,nonatomic)NSInteger columnCount;

/*!
*  列间距，默认是1
*/

@property(assign,nonatomic)NSInteger columnSpacing;

/*!
* 行间距，默认是1
*/

@property(assign,nonatomic)NSInteger rowSpacing;

/*!
* section与collectionView的间距，默认是（5，5，5，5）
*/

@property(assign,nonatomic)UIEdgeInsets sectionInset;

/*!
* 最大选择数量 默认9
*/

@property(assign,nonatomic)NSInteger maxCount;

/*!
* 选中的照片
*/

@property(strong,nonatomic)NSArray<PHAsset *>*selectItems;

//设置代理

@property (nonatomic,weak) id<ZFPhotoPickerViewControllerDelegate> pickerDelegate;


//使用相册方法 

ZFPickerPhotoViewController *photoViewController = [[ZFPickerPhotoViewController alloc] init];
photoViewController.pickerDelegate = self;
photoViewController.selectItems = self.dataArr;
[self presentViewController:photoViewController animated:YES completion:NULL];


![image](https://github.com/linzaifei/ZFPhotoAlbum/blob/master/ZFPhotoAlbum/ZFPhotoAlbumPhotos/camar%1Ce.png)
![image](https://github.com/linzaifei/ZFPhotoAlbum/blob/master/ZFPhotoAlbum/ZFPhotoAlbumPhotos/photo.png)
