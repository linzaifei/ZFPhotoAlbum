//
//  ZFBrowsePhotoViewController.m
//  ZFPhotoAlbum
//
//  Created by xsy on 2017/5/3.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFBrowsePhotoViewController.h"
#import "ZFPhotoAlbum.h"
#import "ZFBrowCollectionCell.h"
#import "ZFPhotoHeadView.h"
#import "ZFCommonTransition.h"
#define  MIN_Space 20
@interface ZFBrowsePhotoViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property(strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)ZFBrowHeadViewBar *browHeadViewBar;
@property(strong,nonatomic)NSIndexPath *lastIndexPath;

@end

@implementation ZFBrowsePhotoViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//   [self.collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
//    self.navigationController.delegate = self;
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
//    [self.collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
//    [self.notificationModel addObserver:self forKeyPath:@"seletedPhotos" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)setUI{
    
    _browHeadViewBar = [[ZFBrowHeadViewBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavigationHeight)];
//    _browHeadViewBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_browHeadViewBar];
//    _browHeadViewBar.count = self.notificationModel.seletedPhotos.count;
    ScrollLayout *layout = [[ScrollLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = MIN_Space;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kNavigationHeight, kScreenWidth, kScreenHeight - kNavigationHeight) collectionViewLayout:layout];
//    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    //减速时的速率,快速减速()
//    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[ZFBrowCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFBrowCollectionCell class])];
    
    //设置偏移量 scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:NO 这个方法在没有调用 只是因为 collectionview 没有布局好 只能用最笨的办法
    self.collectionView.contentOffset = CGPointMake( self.collectionView.frame.size.width * _currentIndex - _currentIndex * MIN_Space, 0);
    
    ////-----
    __weak ZFBrowsePhotoViewController *ws = self;
    
    self.browHeadViewBar.cancelBlock = ^{
        if (ws.cancelBrowBlock) {
            ws.cancelBrowBlock(ws.lastIndexPath);
        }
        [ws.navigationController popViewControllerAnimated:YES];
    };
    self.browHeadViewBar.chooseBlock = ^{
        
    };
    self.browHeadViewBar.title = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex,self.photoItems.count];
    
    ///-------布局 使用布局 不知道为什么使用3Dtouch 会报错 暂时换成frame 之后再看看
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_browHeadViewBar]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_browHeadViewBar)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_collectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_collectionView)]];
//
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_browHeadViewBar(==64)]-0-[_collectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_browHeadViewBar,_collectionView)]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    ZFBrowCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFBrowCollectionCell class]) forIndexPath:indexPath];
    
    NSInteger index = self.photoItems.count - indexPath.item - 1;
    id data = self.photoItems[index];
    [cell zf_setAssest:data];
    BOOL isSelected = NO;
    if ([data isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = (PHAsset *)data;
        if ([self.selectedAssetsDic valueForKey:asset.localIdentifier]) {
            isSelected = YES;
        }
    }
    cell.isSelect = isSelected;
    __weak ZFBrowsePhotoViewController *ws = self;
    __weak ZFBrowCollectionCell *weakCell = cell;
    cell.btnSelectBlock = ^(PHAsset *asset, BOOL isSelect) {
        NSString *urlKey = asset.localIdentifier;
        if ([ws.selectedAssetsDic valueForKey:urlKey]) {
            weakCell.isSelect = NO;
//            [[ws.notificationModel mutableArrayValueForKeyPath:@"seletedPhotos"] removeObject:ws.selectedAssetsDic[urlKey]];
            [ws.selectedAssetsDic removeObjectForKey:urlKey];
        }else {
//            if (ws.notificationModel.seletedPhotos.count >= ws.maxCount) {
//                [RemindView showViewWithTitle:[NSString stringWithFormat:@"%@%lu", NSLocalizedString(@"最多选择", nil), (unsigned long)ws.maxCount] location:LocationTypeMIDDLE];
//                return;
//            }
//            weakCell.isSelect = YES;
//            [ws.selectedAssetsDic setObject:asset forKey:urlKey];
//            [[ws.notificationModel mutableArrayValueForKey:@"seletedPhotos"] addObject:asset];
        }
    };
    return cell;
    
}
//单元格已经结束显示时,调用
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //取得结束显示的单元格
    ZFBrowCollectionCell *photoCell = (ZFBrowCollectionCell *)cell;
    //还原滑动视图缩放倍数
    [photoCell.zf_photoScrollView setZoomScale:1 animated:YES];
    self.lastIndexPath = indexPath;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake( kScreenWidth - 40, kScreenHeight - kNavigationHeight * 2);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0,20, 0,20);
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSInteger index = targetContentOffset->x / (kScreenWidth - 40);
    self.browHeadViewBar.title = [NSString stringWithFormat:@"%ld/%ld",index,self.photoItems.count];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"seletedPhotos"]) {
//        _browHeadViewBar.count = self.notificationModel.seletedPhotos.count;
    }
}

#pragma mark - 代理
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0){

    if(operation == UINavigationControllerOperationPush){
        return [[ZFCommonTransition alloc] init];
    }else{
        return nil;
    }
}

-(void)dealloc{
    NSLog(@"销毁%s",__FUNCTION__);
//    [self.notificationModel removeObserver:self forKeyPath:@"seletedPhotos"];
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
