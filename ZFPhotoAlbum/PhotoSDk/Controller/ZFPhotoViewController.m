//
//  ZFPhotoViewController.m
//  Summary
//
//  Created by xinshiyun on 2017/4/12.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPhotoViewController.h"
#import "ZFPhotoHeadView.h"
#import "ZFPhotoCollectionViewCell.h"
#import "RemindView.h"
#import "ZFPopShowPhotoViewController.h"
#import "ZFBrowsePhotoViewController.h"
#import "ZFCameraViewController.h"
#import "ZFPhotoAlbum.h"
#import "ZFPhotoPresentationVC.h"
#import "ZFPhotoModel.h"
#import "ZFAlbumModel.h"


@interface ZFPhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate, UIImagePickerControllerDelegate,ZFCameraViewDelegate,PHPhotoLibraryChangeObserver>
@property(strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)ZFCameraViewController *camareViewController;
@property(strong,nonatomic)ZFPhotoHeadView *photoHeadView;


@property(strong,nonatomic)NSArray *albums;//相册数据
@property(strong,nonatomic)NSMutableArray *allObjs;//所有照片数据
@property(strong,nonatomic)NSArray *photos;//照片数据
@property(strong,nonatomic)NSArray *videoPhotos;//视频数据

@end

@implementation ZFPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self zf_setUI];
    [self getAlumAuth];
    [self.photoManager addObserver:self forKeyPath:@"selectedPhotos" options:NSKeyValueObservingOptionNew context:nil];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [self.navigationController setNavigationBarHidden:YES animated:YES];
}

/** 获取相册权限 */
-(void)getAlumAuth{

    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self loadData];
    }else{
    WeakSelf(ws)
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
            if (status == PHAuthorizationStatusAuthorized) {
                [ws loadData];
               
            }else{
                [self zf_alert];
            }
        }];
    }
}

-(void)zf_alert{
    // 获取APP名称
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appName  = [info objectForKey:@"CFBundleDisplayName"];
    appName            = appName ? appName : [info objectForKey:@"CFBundleName"];
    NSString *message  = [NSString stringWithFormat:@"请在系统设置中允许“%@”访问照片!", appName];
    
    UIAlertController *alertVC =[UIAlertController alertControllerWithTitle:NSLocalizedString(@"无法访问照片", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSURL *url = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
//        if ([[UIApplication sharedApplication] canOpenURL:url]) {
//            [[UIApplication sharedApplication] openURL:url];
//        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:ok];
    [alertVC addAction:cancel];
    
    [self presentViewController:alertVC animated:YES completion:NULL];


}

#pragma mark - 加载数据
-(void)loadData{
    __weak ZFPhotoViewController *ws = self;

    [self.photoManager zf_getAlbumList:^(NSArray *albums) {
        ws.albums = albums;
        ZFAlbumModel *model = albums.firstObject;
        
        [ws.photoManager zf_getPhotoForPHFetchResult:model.result WithIsAddCamera:YES PhotosList:^(NSArray *photos, NSArray *videos, NSArray *allObjs) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ws.photoHeadView.title = model.albumName;
                ws.allObjs = [allObjs mutableCopy];
                ws.photos = photos;
                ws.videoPhotos = videos;
                [ws.collectionView reloadData];
            });
        }];
    }];
}
#pragma mark - 设置UI
-(void)zf_setUI{
    if(self.photoManager.columnCount > 5 || self.photoManager.columnCount < 3){
        self.photoManager.columnCount = 3;
    }
    self.photoHeadView = [ZFPhotoHeadView new];
    self.photoHeadView.barTintColor = [UIColor whiteColor];
    self.photoHeadView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.photoHeadView];
    self.photoHeadView.count = self.photoManager.selectedPhotos.count;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = self.photoManager.rowSpacing;
    layout.minimumInteritemSpacing = self.photoManager.columnSpacing;
    layout.sectionInset = self.photoManager.sectionInset;
    CGFloat itemWidth = (kScreenWidth - self.photoManager.rowSpacing * (self.photoManager.columnCount - 1) - self.photoManager.sectionInset.left - self.photoManager.sectionInset.right) / self.photoManager.columnCount;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[ZFPhotoCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFPhotoCollectionViewCell class])];
    
    //用于3Dtouch
   // [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
    
    
   WeakSelf(ws);
    [self.photoHeadView setDidClickWithType:^(ZFClickType type, UIButton *btn) {
        switch (type) {
            case ZFClickTypeBack:
                [ws zf_dismess];
                break;
            case ZFClickTypeNext:{
                if (ws.didSelectPhotosBlock) {
                    ws.didSelectPhotosBlock(ws.photoManager.selectedPhotos);
                }else{
                    if ([ws.delegate respondsToSelector:@selector(photoPickerViewController:didSelectPhotos:)]) {
                        [ws.delegate photoPickerViewController:ws didSelectPhotos:ws.photoManager.selectedPhotos];
                    }
                }
                [ws dismissViewControllerAnimated:YES completion:NULL];
            }break;
                case ZFClickTypeTitle:
                [ws zf_showPhotoViewController];
                break;
            default:
                break;
        }
        
    }];
    
    ///-------布局
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_photoHeadView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoHeadView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_collectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_photoHeadView(==64)]-0-[_collectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_photoHeadView,_collectionView)]];
}

#pragma mark - 点击标题
//下拉选择
-(void)zf_showPhotoViewController{
    ZFPopShowPhotoViewController *showViewController = [[ZFPopShowPhotoViewController alloc] init];
    showViewController.dataArr = self.albums;
    __weak ZFPhotoViewController *ws = self;
    showViewController.didSelectBlock = ^(NSArray *dataArr, NSInteger index) {
        ZFAlbumModel *model = dataArr[index];
        ws.photoHeadView.title = model.albumName;
        BOOL isAdd = NO;
        if (index == 0) {
            isAdd = YES;
        }
        [ws.photoManager zf_getPhotoForPHFetchResult:model.result WithIsAddCamera:isAdd PhotosList:^(NSArray *photos, NSArray *videos, NSArray *allObjs) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ws.allObjs = [allObjs mutableCopy];
                ws.photos = photos;
                ws.videoPhotos = videos;
                [ws.collectionView reloadData];
                [ws.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            });
        }];
    };
    [self presentViewController:showViewController animated:YES completion:NULL];
}

#pragma mark - CollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.allObjs.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZFPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFPhotoCollectionViewCell class]) forIndexPath:indexPath];
    cell.model = self.allObjs[indexPath.item];
    __weak ZFPhotoViewController *ws = self;
    
    [cell zf_setClickItem:^(ZFPhotoCollectionViewCell *selectCell,ZFPhotoModel *model, BOOL isSelect) {
        [ws didClickSelectCell:selectCell Model:model IsSelect:isSelect];
    }];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    //cell消失取消加载
    ZFPhotoCollectionViewCell *zfCell = (ZFPhotoCollectionViewCell *)cell;
    if (zfCell.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:zfCell.requestID];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ZFPhotoModel *model = self.allObjs[indexPath.item];
    switch (model.type) {
        case ZFPhotoModelMediaTypeCamera://跳转相机
            [self goCameraViewController];
            break;
        case ZFPhotoModelMediaTypePhoto://照片,live照片
        case ZFPhotoModelMediaTypeLivePhoto:{
            NSLog(@"点击照片");
            ZFBrowsePhotoViewController *browsePhotoViewController = [[ZFBrowsePhotoViewController alloc] init];
            browsePhotoViewController.currentIndex = indexPath.item;
            self.navigationController.delegate = browsePhotoViewController;
            browsePhotoViewController.photoManager = self.photoManager;
            browsePhotoViewController.photoItems = self.allObjs;
            [self.navigationController pushViewController:browsePhotoViewController animated:YES];
        }break;
        case ZFPhotoModelMediaTypeVideo://视屏
            NSLog(@"视频");
            break;
            
        default:
            break;
    }
    


}
- (void)goCameraViewController {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [RemindView showViewWithTitle:NSLocalizedString(@"此设备不支持相机!", nil) location:LocationTypeMIDDLE];
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在设置-隐私-相机中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
        return;
    }
    ZFCameraType type = 0;
    if (self.photoManager.type == ZFPhotoMangerSelectTypePhotoAndVideo) {
        
    }else if (self.photoManager.type == ZFPhotoModelMediaTypePhoto) {
        type = ZFCameraTypePhoto;
    }else if (self.photoManager.type == ZFPhotoModelMediaTypeVideo) {
        type = ZFCameraTypeVideo;
    }
    if (self.photoManager.showFullScreenCamera) {

    }else {
        ZFCameraViewController *vc = [[ZFCameraViewController alloc] initWithCameraType:ZFCameraPopTypeCustom];
        vc.cameraDelegate = self;
        vc.type = type;
        vc.photoManager = self.photoManager;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark -
-(void)didClickSelectCell:(ZFPhotoCollectionViewCell *)selectCell Model:(ZFPhotoModel *)model IsSelect:(BOOL)isSelected{
    
    if (isSelected) {//选中
        NSString *max = [NSString stringWithFormat:@"最多选择%ld张",self.photoManager.maxCount];
        
        if (model.type == ZFPhotoModelMediaTypeLivePhoto) {
            [selectCell startLivePhoto];
        }
        
        if (model.type == ZFPhotoModelMediaTypeCamera) {
           
            
        }else if (model.type == ZFPhotoModelMediaTypePhoto || model.type == ZFPhotoModelMediaTypeLivePhoto){
            if (self.photoManager.selectedPhotos.count == self.photoManager.maxCount) {
                [RemindView showViewWithTitle:NSLocalizedString(max, nil) location:LocationTypeMIDDLE];
                // 已经达到图片最大选择数
                selectCell.isSelected = NO;
                return;
            }
            model.selected = isSelected;
            [[self.photoManager mutableArrayValueForKey:@"selectedPhotos"] addObject:model];
        }else if (model.type == ZFPhotoModelMediaTypeVideo){
            
            
        }
    }else{//取消选中
        if (model.type == ZFPhotoModelMediaTypeLivePhoto) {
            [selectCell stopLivePhoto];
        }

        for (ZFPhotoModel *subModel in self.photoManager.selectedPhotos) {
        
            if (model.type == ZFPhotoModelMediaTypeCamera) {
                
                
            }else if (model.type == ZFPhotoModelMediaTypePhoto || model.type == ZFPhotoModelMediaTypeLivePhoto){
                if ([subModel.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [[self.photoManager mutableArrayValueForKey:@"selectedPhotos"] removeObject:subModel];
                }
                model.selected = isSelected;
            }else if (model.type == ZFPhotoModelMediaTypeVideo){
                
                
            }
        }
        
    }

}


#pragma mark - 添加观察者
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"selectedPhotos"]) {
        self.photoHeadView.count = self.photoManager.selectedPhotos.count;
    }
}
#pragma mark - ZFCameraViewDelegate
-(void)zf_photoCapViewController:(UIViewController *)viewController didFinishDismissWithPhoto:(ZFPhotoModel *)model{
    if(self.photoManager.selectedPhotos.count == self.photoManager.maxCount){
        model.selected = NO;
        [self.allObjs insertObject:model atIndex:1];
        [self.collectionView reloadData];
        return;
    }
    [self.allObjs insertObject:model atIndex:1];
    [[self.photoManager mutableArrayValueForKey:@"selectedPhotos"] addObject:model];
    [self.collectionView reloadData];
}
#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    /*
    __weak ZFPhotoViewController *ws = self;
    NSMutableArray *mutableArr = [self.albums mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [mutableArr enumerateObjectsUsingBlock:^(ZFAlbumModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
           PHFetchResultChangeDetails *deltails = [changeInstance changeDetailsForFetchResult:obj.result];
            NSLog(@"%d",deltails.hasIncrementalChanges);
            if(deltails.hasIncrementalChanges){
                PHAsset *asset = deltails.fetchResultAfterChanges.lastObject;
                NSLog(@"asset lat =%@",asset.localIdentifier);
                ZFPhotoModel *model = [[ZFPhotoModel alloc] init];
                model.asset = asset;
                model.selected = YES;
                [ws.allObjs insertObject:model atIndex:1];
                [[ws.photoManager mutableArrayValueForKey:@"selectedPhotos"] addObject:model];
                [ws.collectionView reloadData];
                *stop = YES;
            }
        }];
    });
*/
}
/** 销毁 */
-(void)zf_dismess{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 通知
-(void)zf_closeNotifer{
    [self.photoHeadView zfScoll];
}

#pragma mark --- 懒加载

#pragma mark  --- 相册获取参考数据
//获取自定义相册簿 （自己创建的相册）
/*
 Album //从 iTunes 同步来的相册，以及用户在 Photos 中自己建立的相册
 SmartAlbum //经由相机得来的相册
 Moment //Photos 为我们自动生成的时间分组的相册
 */


/*
 enum PHAssetCollectionSubtype : Int {
 case AlbumRegular //用户在 Photos 中创建的相册，也就是我所谓的逻辑相册
 case AlbumSyncedEvent //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步过来的事件。然而，在iTunes 12 以及iOS 9.0 beta4上，选用该类型没法获取同步的事件相册，而必须使用AlbumSyncedAlbum。
 case AlbumSyncedFaces //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步的人物相册。
 case AlbumSyncedAlbum //做了 AlbumSyncedEvent 应该做的事
 case AlbumImported //从相机或是外部存储导入的相册，完全没有这方面的使用经验，没法验证。
 case AlbumMyPhotoStream //用户的 iCloud 照片流
 case AlbumCloudShared //用户使用 iCloud 共享的相册
 case SmartAlbumGeneric //文档解释为非特殊类型的相册，主要包括从 iPhoto 同步过来的相册。由于本人的 iPhoto 已被 Photos 替代，无法验证。不过，在我的 iPad mini 上是无法获取的，而下面类型的相册，尽管没有包含照片或视频，但能够获取到。
 case SmartAlbumPanoramas //相机拍摄的全景照片
 case SmartAlbumVideos //相机拍摄的视频
 case SmartAlbumFavorites //收藏文件夹
 case SmartAlbumTimelapses //延时视频文件夹，同时也会出现在视频文件夹中
 case SmartAlbumAllHidden //包含隐藏照片或视频的文件夹
 case SmartAlbumRecentlyAdded //相机近期拍摄的照片或视频
 case SmartAlbumBursts //连拍模式拍摄的照片，在 iPad mini 上按住快门不放就可以了，但是照片依然没有存放在这个文件夹下，而是在相机相册里。
 case SmartAlbumSlomoVideos //Slomo 是 slow motion 的缩写，高速摄影慢动作解析，在该模式下，iOS 设备以120帧拍摄。
 case SmartAlbumUserLibrary //这个命名最神奇了，就是相机相册，所有相机拍摄的照片或视频都会出现在该相册中，而且使用其他应用保存的照片也会出现在这里。
 case Any //包含所有类型
 }
 
 
 (2).资源的子类型.
 mediaSubtypes:PHAssetMediaSubtype类型的枚举值:
 PHAssetMediaSubtypeNone               没有任何子类型
 相片子类型
 PHAssetMediaSubtypePhotoPanorama      全景图
 PHAssetMediaSubtypePhotoHDR           滤镜图
 PHAssetMediaSubtypePhotoScreenshot 截屏图
 PHAssetMediaSubtypePhotoLive 1.5s 的 photoLive
 视屏子类型
 PHAssetMediaSubtypeVideoStreamed      流体
 PHAssetMediaSubtypeVideoHighFrameRate 高帧视屏
 PHAssetMediaSubtypeVideoTimelapse   延时拍摄视频
 
 */


/*
 info 信息
 
 PHImageFileOrientationKey = 0;
 PHImageFileSandboxExtensionTokenKey = "298fd95ea90e3a96018632dba00e53e37ad85426;00000000;00000000;000000000000001a;com.apple.app-sandbox.read;00000001;01000003;00000000000382d7;/private/var/mobile/Media/DCIM/100APPLE/IMG_0197.JPG";
 PHImageFileURLKey = "file:///var/mobile/Media/DCIM/100APPLE/IMG_0197.JPG";
 PHImageFileUTIKey = "public.jpeg";
 PHImageResultDeliveredImageFormatKey = 9999;
 PHImageResultIsDegradedKey = 0;
 PHImageResultIsInCloudKey = 0;
 PHImageResultIsPlaceholderKey = 0;
 PHImageResultOptimizedForSharing = 0;
 PHImageResultWantedImageFormatKey = 4035;
 
 
 */
/*
 synchronous：指定请求是否同步执行。
 resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
 deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
 这个属性只有在 synchronous 为 true 时有效。
 normalizedCropRect：用于对原始尺寸的图像进行裁剪，基于比例坐标。只在 resizeMode 为 Exact 时有效。
 */
-(void)dealloc{
    [self.photoManager.selectedPhotos removeAllObjects];
    //销毁观察相册变化的观察者
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [self.photoManager removeObserver:self forKeyPath:@"selectedPhotos"];
    NSLog(@"销毁 %s",__FUNCTION__);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
