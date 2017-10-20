//
//  DropdownListView.h
//  BPMS
//
//  Created by lianditech on 2017/10/13.
//  Copyright © 2017年 啾三万. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropdownListView : UIView

@property (nonatomic, copy) NSArray<NSString *> *dataArray;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) UIFont *itemFont;//字体大小 默认13
@property (nonatomic, strong) UIColor *itemTextColor;//字体颜色 默认blackColor
@property (nonatomic, strong) UIColor *itemBorderColor;//边框色 默认lightGrayColor

@property (nonatomic, copy) void (^clickDropBlock)(BOOL);
@property (nonatomic, copy) void (^selectBlock)(NSInteger);

@end
