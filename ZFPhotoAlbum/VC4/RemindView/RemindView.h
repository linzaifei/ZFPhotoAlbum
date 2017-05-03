//
//  RemindView.h
//  Live
//
//  Created by xsy on 16/8/5.
//  Copyright © 2016年 林再飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LocationType) {
    
   LocationTypeTOP = 0,//顶部
   LocationTypeMIDDLE,//中间
   LocationTypeBELLOW//下部
};

@interface RemindView : NSObject

+(void)showViewWithTitle:(NSString *)title location:(LocationType)location;

@end
