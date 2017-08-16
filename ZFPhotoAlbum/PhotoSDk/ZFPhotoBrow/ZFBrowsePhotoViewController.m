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
#import "ZFBtn.h"
#import "ZFPhotoModel.h"
@interface ZFBrowsePhotoViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIViewControllerTransitioningDelegate>
@property(strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)ZFBrowHeadViewBar *browHeadViewBar;
@property(strong,nonatomic)ZFBtn *selectBtn;
//@property(strong,nonatomic)NSIndexPath *lastIndexPath;
@property(strong,nonatomic)ZFCommonTransition *commonTransition;

@end

@implementation ZFBrowsePhotoViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self didSelectCell];
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
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.photoManager addObserver:self forKeyPath:@"selectedPhotos" options:NSKeyValueObservingOptionNew context:nil];
    [self setUI];
}

-(void)setUI{
    
    _browHeadViewBar = [[ZFBrowHeadViewBar alloc] init];
    _browHeadViewBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_browHeadViewBar];
    _browHeadViewBar.count = self.photoManager.selectedPhotos.count;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight - kNavigationHeight);
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //设置偏移量
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentSize = CGSizeMake(self.photoItems.count * (kScreenWidth + 20), 0);
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[ZFBrowCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFBrowCollectionCell class])];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * (kScreenWidth + 20), 0) animated:NO];
    
    
    self.selectBtn = [ZFBtn new];
    self.selectBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectBtn.frame = CGRectMake(0, 0, 60, 30);
    [_selectBtn setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"compose_guide_check_box_default"]] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:[@"ZFPhotoBundle.bundle" stringByAppendingPathComponent:@"compose_guide_check_box_right"]] forState:UIControlStateSelected];
    
    [self.selectBtn addTarget:self action:@selector(clickSelectImg:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.selectBtn];
    
   
    
    //-----
    __weak ZFBrowsePhotoViewController *ws = self;
    self.browHeadViewBar.cancelBlock = ^{
//        if (ws.cancelBrowBlock) {
//            ws.cancelBrowBlock(ws.lastIndexPath);
//        }
        [ws.navigationController popViewControllerAnimated:YES];
    };
    self.browHeadViewBar.chooseBlock = ^{
        
    };
    self.browHeadViewBar.title = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex,self.photoItems.count];
    
    
    ///-------布局 使用布局 不知道为什么使用3Dtouch 会报错 暂时换成frame 之后再看看
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_selectBtn]-20-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_selectBtn)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[_selectBtn]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_selectBtn)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_browHeadViewBar]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_browHeadViewBar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-width-[_collectionView]-width-|" options:0 metrics:@{@"width":@(-10)} views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_browHeadViewBar(==64)]-0-[_collectionView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_collectionView,_browHeadViewBar)]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    ZFBrowCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFBrowCollectionCell class]) forIndexPath:indexPath];
    cell.model = self.photoItems[indexPath.item];

    return cell;
    
}
//单元格已经结束显示时,调用
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //取得结束显示的单元格
    ZFBrowCollectionCell *photoCell = (ZFBrowCollectionCell *)cell;
    //还原滑动视图缩放倍数
    [photoCell.photoScrollView setZoomScale:1 animated:YES];
//    self.lastIndexPath = indexPath;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [ self didSelectCell];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat offsetx = scrollView.contentOffset.x;
    NSInteger currentIndex = (offsetx + (width + 20) * 0.5) / (width + 20);
    if (currentIndex > self.photoItems.count - 1) {
        currentIndex = self.photoItems.count - 1;
    }
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    self.browHeadViewBar.title = [NSString stringWithFormat:@"%ld/%ld",currentIndex + 1,self.photoItems.count];
    ZFPhotoModel *model = self.photoItems[currentIndex];
    self.selectBtn.selected = model.selected;
    self.currentIndex = currentIndex;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"selectedPhotos"]) {
        _browHeadViewBar.count = self.photoManager.selectedPhotos.count;
    }
}

#pragma mark - Mor
-(void)clickSelectImg:(ZFBtn *)btn{

    ZFPhotoModel *model = self.photoItems[self.currentIndex];
    
    
    
    if (btn.selected) {
        model.selected = NO;
        [self.photoManager.selectedPhotos enumerateObjectsUsingBlock:^(ZFPhotoModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                [[self.photoManager mutableArrayValueForKey:@"selectedPhotos"] removeObject:model];
            }
        }];
    }else{
        if (self.photoManager.maxCount == self.photoManager.selectedPhotos.count) {
            
            NSString *max = [NSString stringWithFormat:@"最多可以选择%ld",self.photoManager.maxCount];
            [RemindView showViewWithTitle:NSLocalizedString(max, nil) location:LocationTypeMIDDLE];
            return;
        }
        model.selected = YES;
        [[self.photoManager mutableArrayValueForKey:@"selectedPhotos"] addObject:model];
    }
    
    self.selectBtn.selected = model.selected;
    NSLog(@"%@",self.photoManager.selectedPhotos);
}

#pragma mark - selected

-(void)didSelectCell{
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
    ZFBrowCollectionCell *cell = (ZFBrowCollectionCell *)[self.collectionView cellForItemAtIndexPath:path];
    ZFPhotoModel *model = self.photoItems[self.currentIndex];
    self.selectBtn.selected = model.selected;
    if (model.type == ZFPhotoModelMediaTypeLivePhoto) {
        
    }else if (model.type == ZFPhotoModelMediaTypeVideo){
        
    }else{
        
    }
    [cell setHightImg];
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

#pragma mark - 懒加载
-(ZFCommonTransition *)commonTransition{
    if (_commonTransition == nil) {
        _commonTransition = [[ZFCommonTransition alloc] init];
    }
    return _commonTransition;
}



-(void)dealloc{
    NSLog(@"销毁%s",__FUNCTION__);
    [self.photoManager removeObserver:self forKeyPath:@"selectedPhotos"];
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
