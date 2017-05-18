//
//  HGesturesPasswordView.h
//  HGesturesPassword
//
//  Created by yyh on 2017/5/17.
//  Copyright © 2017年 yyh. All rights reserved.
//

#define kNormalColor [UIColor grayColor]  //默认颜色
#define kSelectColor [UIColor blueColor]  //选中颜色
#define kErrorColor  [UIColor redColor]   //错误颜色

#import <UIKit/UIKit.h>

typedef void(^returnBlock)(NSMutableArray *resultArray);

@interface HGesturesPasswordView : UIView

- (instancetype)initWithFrame:(CGRect)frame resultView:(BOOL)resultView block:(returnBlock)block;
- (void)showResultWith:(NSMutableArray *)array;
- (void)showError;

@end
