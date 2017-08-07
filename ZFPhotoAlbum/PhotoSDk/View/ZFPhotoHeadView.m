//
//  ZFPhotoHeadView.m
//  Summary
//
//  Created by xinshiyun on 2017/4/12.
//  Copyright © 2017年 林再飞. All rights reserved.
//

#import "ZFPhotoHeadView.h"
#import "ZFPhotoTools.h"
#import "ZFPhotoAlbum.h"
@interface ZFPhotoHeadView()
@property(strong,nonatomic)ZFTitleView *titleBtn;
@property(strong,nonatomic)UIButton *chooseBtn;
@end
@implementation ZFPhotoHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setUI];
    }
    return self;
}

-(void)setUI{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    backBtn.frame = CGRectMake(0, 0, 70, 30);
    
    [backBtn setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"camera_edit_cross.png"] forState:UIControlStateNormal];
    [backBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 1, 0, 0)];
    
    self.titleBtn = [[ZFTitleView alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    self.titleBtn.title = NSLocalizedString(@"全部相册", nil);
    
    
    self.chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.chooseBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [self.chooseBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.chooseBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.chooseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.chooseBtn.frame = CGRectMake(0, 0, 80, 25);
    self.chooseBtn.layer.masksToBounds = YES;
    self.chooseBtn.layer.cornerRadius = 3;
    self.chooseBtn.userInteractionEnabled = NO;
    [self.chooseBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.chooseBtn];
    item.titleView = self.titleBtn;
    
    [self pushNavigationItem:item animated:YES];
    
    [backBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.chooseBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.tag = 300;
    self.chooseBtn.tag = 301;
    _titleBtn.tag = 302;
}

-(void)clickBtn:(UIButton *)btn{
    switch (btn.tag - 300) {
        case 0:
            if (self.cancelBlock) {
                self.cancelBlock();
            }
            break;
        case 1:
            if (self.chooseBlock) {
                self.chooseBlock();
            }
            break;
        case 2:
            [self.titleBtn zfScoll];
            if (self.titleBlock) {
                self.titleBlock();
            }
            break;
        default:
            break;
    }
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleBtn.title = title;
}
-(void)zfScoll{
    [self.titleBtn zfScoll];
}

-(void)setCount:(NSInteger)count{
    _count = count;
    if (count == 0) {
        self.chooseBtn.userInteractionEnabled = NO;
        [self.chooseBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.chooseBtn setTitle:@"下一步" forState:UIControlStateNormal];
        self.chooseBtn.backgroundColor = [UIColor clearColor];
        self.chooseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    }else{
        self.chooseBtn.userInteractionEnabled = YES;
        [self.chooseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.chooseBtn setTitle:[NSString stringWithFormat:@"下一步(%ld)",count] forState:UIControlStateNormal];
        self.chooseBtn.backgroundColor = [UIColor orangeColor];
        self.chooseBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    
}


@end


@interface ZFTitleView ()
@property(strong,nonatomic)UILabel *label;
@property(strong,nonatomic)UIImageView *imageV;
@end
@implementation ZFTitleView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self= [super initWithFrame:frame] ) {
        [self setUI];
    }
    return self;
}
-(void)setUI{

    self.label = [UILabel new];
    self.label.textColor = [UIColor blackColor];
    self.label.font = [UIFont systemFontOfSize:15];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.label];
    
    self.imageV = [UIImageView new];
    self.imageV.image = [ZFPhotoTools zf_getPhotoWithImgName:@"common_icon_arrow.png"];
    self.imageV.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.imageV];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-2-[_label]-5-[_imageV]-2-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_label,_imageV)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:1]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_imageV attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:1]];
}

-(void)setTitle:(NSString *)title{
    _title = title;
    _label.text = title;
}
-(void)zfScoll{
    __weak ZFTitleView *ws = self;
    [UIView animateWithDuration:0.3 animations:^{
        ws.imageV.transform = CGAffineTransformRotate(ws.imageV.transform, M_PI);
    }];
}



@end

@interface ZFCamareHeadView()
@property(strong,nonatomic)UIButton *titleBtn;
@end
@implementation ZFCamareHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

-(void)setUI{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    
    [backBtn setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"camera_edit_cross.png"]forState:UIControlStateNormal];
    
    self.titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleBtn setTitle:NSLocalizedString(@"相机", nil) forState:UIControlStateNormal];
    [self.titleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.titleBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleBtn.frame = CGRectMake(0, 0, 50, 30);
    
    
    UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"camera_flashlight_auto_disable"]forState:UIControlStateNormal];
    [flashBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    flashBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    flashBtn.frame = CGRectMake(0, 0, 40, 25);
    
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeBtn setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"camera_overturn.png"] forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    changeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    changeBtn.frame = CGRectMake(0, 0, 40, 25);
    
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:flashBtn];
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithCustomView:changeBtn];
    item.rightBarButtonItems = @[rightItem,rightItem1];
    item.titleView = self.titleBtn;
    
    [self pushNavigationItem:item animated:YES];
    
    [backBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [flashBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [changeBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.tag = 310;
    flashBtn.tag = 311;
    changeBtn.tag = 312;
    
}

-(void)clickBtn:(UIButton *)btn{
    switch (btn.tag - 310) {
        case 0:
            if (self.cancelBlock) {
                self.cancelBlock();
            }
            break;
        case 1:
            if (self.flashBlock) {
                self.flashBlock(btn);
            }
            break;
        case 2:
            if (self.changeBlock) {
                self.changeBlock();
            }
            break;
        default:
            break;
    }
}

@end


@interface ZFTakePhotoHeadView()
@property(strong,nonatomic)UIButton *takePhotoBtn;
@property(strong,nonatomic)UIButton *cancelBtn;
@property(strong,nonatomic)UIButton *chooseBtn;
@end
@implementation ZFTakePhotoHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

-(void)setUI{
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelBtn setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"icon_delImg"] forState:UIControlStateNormal];
    [self addSubview:self.cancelBtn];
    
    self.takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.takePhotoBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.takePhotoBtn setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"camera_camera_background"] forState:UIControlStateNormal];
    [self addSubview:self.takePhotoBtn];
    
    self.chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chooseBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.chooseBtn setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"icon_taked"] forState:UIControlStateNormal];
    [self addSubview:self.chooseBtn];
    
    [self.takePhotoBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.chooseBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelBtn.tag = 320;
    self.takePhotoBtn.tag = 321;
    self.chooseBtn.tag = 322;
    self.cancelBtn.hidden = YES;
    self.chooseBtn.hidden = YES;
    CGFloat Width = kScreenWidth / 3.0;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_cancelBtn(==width)]-0-[_takePhotoBtn(==width)]-0-[_chooseBtn(==width)]-0-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"width":@(Width)} views:NSDictionaryOfVariableBindings(_cancelBtn,_chooseBtn,_takePhotoBtn)]];
    
       [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

}

-(void)clickBtn:(UIButton *)btn{
    BOOL istake = NO;
    switch (btn.tag - 320) {
        case 0:
            if(self.cancelBlock){
                self.cancelBlock();
            }
            break;
        case 1:
            if (self.takePhotoBlock) {
                self.takePhotoBlock();
            }
            istake = YES;
            break;
        case 2:
            if(self.chooseBlock){
                self.chooseBlock();
            }
            break;
            
        default:
            break;
    }
    self.cancelBtn.hidden = self.chooseBtn.hidden = !istake;
    self.takePhotoBtn.hidden = istake;
}

@end



@interface ZFBrowHeadViewBar()
@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UIButton *chooseBtn;
@end

@implementation ZFBrowHeadViewBar
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

-(void)setUI{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    backBtn.frame = CGRectMake(0, 0, 70, 30);
    
    [backBtn setImage:[ZFPhotoTools zf_getPhotoWithImgName:@"camera_edit_cross.png"] forState:UIControlStateNormal];
    [backBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 1, 0, 0)];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.chooseBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [self.chooseBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.chooseBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.chooseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.chooseBtn.frame = CGRectMake(0, 0, 80, 25);
    self.chooseBtn.layer.masksToBounds = YES;
    self.chooseBtn.layer.cornerRadius = 3;
    self.chooseBtn.userInteractionEnabled = NO;
    [self.chooseBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.chooseBtn];
    item.titleView = self.titleLabel;
    
    [self pushNavigationItem:item animated:YES];
    
    [backBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.chooseBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.tag = 340;
    self.chooseBtn.tag = 341;
}

-(void)clickBtn:(UIButton *)btn{
    switch (btn.tag - 340) {
        case 0:
            if (self.cancelBlock) {
                self.cancelBlock();
            }
            break;
        case 1:
            if (self.chooseBlock) {
                self.chooseBlock();
            }
            break;
        default:
            break;
    }
}

-(void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

-(void)setCount:(NSInteger)count{
    _count = count;
    if (count == 0) {
        self.chooseBtn.userInteractionEnabled = NO;
        [self.chooseBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.chooseBtn setTitle:@"下一步" forState:UIControlStateNormal];
        self.chooseBtn.backgroundColor = [UIColor clearColor];
        self.chooseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    }else{
        self.chooseBtn.userInteractionEnabled = YES;
        [self.chooseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.chooseBtn setTitle:[NSString stringWithFormat:@"下一步(%ld)",count] forState:UIControlStateNormal];
        self.chooseBtn.backgroundColor = [UIColor orangeColor];
        self.chooseBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    
}
@end
