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
#import "ZFPhotoManger.h"
#define  MIN_Space 0
@interface ZFBrowsePhotoViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIViewControllerTransitioningDelegate>
@property(strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)ZFBrowHeadViewBar *browHeadViewBar;
@property(strong,nonatomic)NSIndexPath *lastIndexPath;
@property(strong,nonatomic)ZFCommonTransition *commonTransition;

@end

@implementation ZFBrowsePhotoViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(instancetype)init{
    if (self = [super init]) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
}

-(void)setUI{
    
    _browHeadViewBar = [[ZFBrowHeadViewBar alloc] init];
    _browHeadViewBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_browHeadViewBar];
    _browHeadViewBar.count = self.photoManager.selectedPhotos.count;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 20;
     layout.itemSize = CGSizeMake(kScreenWidth, kNavigationHeight - 64);
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = MIN_Space;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor purpleColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    //减速时的速率,快速减速()
//    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[ZFBrowCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFBrowCollectionCell class])];
    
    //设置偏移量
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
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_browHeadViewBar]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_browHeadViewBar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_collectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_collectionView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_browHeadViewBar(==64)]-0-[_collectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_browHeadViewBar,_collectionView)]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    ZFBrowCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFBrowCollectionCell class]) forIndexPath:indexPath];
    

    
    return cell;
    
}
//单元格已经结束显示时,调用
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //取得结束显示的单元格
    ZFBrowCollectionCell *photoCell = (ZFBrowCollectionCell *)cell;
    //还原滑动视图缩放倍数
    [photoCell.photoScrollView setZoomScale:1 animated:YES];
    self.lastIndexPath = indexPath;
}



-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSInteger index = targetContentOffset->x / (kScreenWidth - 40);
    self.browHeadViewBar.title = [NSString stringWithFormat:@"%ld/%ld",index,self.photoItems.count];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"seletedPhotos"]) {
        
    }
}

#pragma mark - 代理
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation
    fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0){
    if(operation == UINavigationControllerOperationPush){
        self.commonTransition.type = ZFTransitionTypePush;
        return self.commonTransition;
    }else{
        self.commonTransition.type = ZFTransitionTypePop;
        return self.commonTransition;
    }
}

//- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
//
//    
//
//}
//
//- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
//
//}

#pragma mark - 懒加载
-(ZFCommonTransition *)commonTransition{
    if (_commonTransition == nil) {
        _commonTransition = [[ZFCommonTransition alloc] init];
    }
    return _commonTransition;
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
