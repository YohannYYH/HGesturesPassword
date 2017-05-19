//
//  HGesturesPasswordVC.h
//  HGesturesPassword
//
//  Created by yyh on 2017/5/17.
//  Copyright © 2017年 yyh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HGesturesPasswordType) {
    
    HGesturesPasswordType_Create  = 0,  // 创建手势密码
    HGesturesPasswordType_Check   = 1,  // 验证
//    HGesturesPasswordType_Edit    = 2,  // 修改
//    HGesturesPasswordType_Delete  = 3,  // 删除
};

@interface HGesturesPasswordVC : UIViewController

@property (assign, nonatomic) HGesturesPasswordType type;

@end
