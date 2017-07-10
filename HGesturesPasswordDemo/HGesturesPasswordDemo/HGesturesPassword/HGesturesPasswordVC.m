//
//  HGesturesPasswordVC.m
//  HGesturesPassword
//
//  Created by yyh on 2017/5/17.
//  Copyright © 2017年 yyh. All rights reserved.
//

#define kPsw              @"kPsw"
#define UI_SCREEN_WIDTH   ([[UIScreen mainScreen] bounds].size.width)
#define kResultViewWidth  60
#define kPswViewWidth     350

#import "HGesturesPasswordVC.h"
#import "HGesturesPasswordView.h"

@interface HGesturesPasswordVC ()

@property (strong, nonatomic) HGesturesPasswordView *pswView;
@property (strong, nonatomic) HGesturesPasswordView *resultView;

@property (strong, nonatomic) UILabel *tipsLabel;
@property (strong, nonatomic) UIButton *resetButton;

@property (copy, nonatomic) NSString *psw;
@property (copy, nonatomic) NSString *verifyPsw;
@property (assign, nonatomic) NSInteger errorCount;

@end

@implementation HGesturesPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initViews];
}

- (void)initViews {
    
    [self.view addSubview:self.resultView];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.pswView];
    [self.view addSubview:self.resetButton];
}

- (UIButton *)resetButton {
    
    if (!_resetButton) {
        
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resetButton setFrame:CGRectMake(0, CGRectGetMaxY(self.pswView.frame) + 5, UI_SCREEN_WIDTH, 40)];
        [_resetButton setTitleColor:kNormalColor forState:UIControlStateNormal];
        _resetButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_resetButton setTitle:[self originalButtonTitle] forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _resetButton;
}

- (UILabel *)tipsLabel {
    
    if (!_tipsLabel) {
        
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.resultView.frame) + 5, UI_SCREEN_WIDTH, 20)];
        _tipsLabel.textColor = kNormalColor;
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        _tipsLabel.text = [self originalTips];
    }
    
    return _tipsLabel;
}

- (HGesturesPasswordView *)resultView {
    
    if (!_resultView) {
        
        _resultView = [[HGesturesPasswordView alloc] initWithFrame:CGRectMake((UI_SCREEN_WIDTH - kResultViewWidth) / 2, 80, kResultViewWidth, kResultViewWidth)
                                                        resultView:NO
                                                          block:nil];
    }
    
    return _resultView;
}

- (HGesturesPasswordView *)pswView {
    
    if (!_pswView) {
        
        __weak HGesturesPasswordVC *blockself = self;
        _pswView = [[HGesturesPasswordView alloc] initWithFrame:CGRectMake((UI_SCREEN_WIDTH - kPswViewWidth) / 2, 150, kPswViewWidth, kPswViewWidth)
                                                     resultView:YES
                                                          block:^(NSMutableArray *resultArray) {
            
                                                              [blockself.resultView showResultWith:resultArray];
                                                              [blockself resultManageWith:resultArray];
                                                          }];
    }
    
    return _pswView;
}

- (void)buttonClick {
    
    if (self.type == HGesturesPasswordType_Create) {
        
        self.psw = @"";
        [self showTipsWith:[self originalTips] color:kNormalColor error:NO];
    }else {
        
        [self savePassWord:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)originalButtonTitle {
    
    return self.type == HGesturesPasswordType_Create ? @"重新设置" : @"输入密码登录";
}

- (NSString *)originalTips {
    
    return self.type == HGesturesPasswordType_Create ? @"输入手势密码" : @"验证手势密码";
}

#pragma mark - 密码验证

- (void)resultManageWith:(NSArray *)array {
    
    NSMutableString *pswStr = @"".mutableCopy;
    for (id num in array) {
        
        [pswStr appendString:[NSString stringWithFormat:@"%ld", [num integerValue]]];
    }
    
    NSLog(@"========%@", pswStr);
    
    if (pswStr.length < 4) {
        
        [self showTipsWith:@"密码长度不能小于4" color:kErrorColor error:YES];
    }else {
        
        if (self.type == HGesturesPasswordType_Create) {
            
            [self handle_CreatePswWith:pswStr];
        }else {
            
            [self handle_CheckPswWith:pswStr];
        }
    }
    
}

- (void)handle_CreatePswWith:(NSString *)pswStr {
    
    if (self.psw.length == 0) {
        
        self.psw = pswStr;
        [self showTipsWith:@"再次输入密码" color:kNormalColor error:NO];
    }else {
        
        if ([self.psw isEqualToString:pswStr]) {
            
            [self savePassWord:pswStr];
            [self showAlertViewWith:@"密码设置成功"];
        }else {
            
            [self showTipsWith:@"两次密码输入不一致" color:kErrorColor error:YES];
            [self.pswView showError];
        }
    }
    
}

- (void)handle_CheckPswWith:(NSString *)pswStr {
    
    if (![self getPassWord]) {
        
        [self showTipsWith:@"还未设置密码" color:kErrorColor error:YES];
        return;
    }
    
    if ([pswStr isEqualToString:[self getPassWord]]) {
        
        [self showAlertViewWith:@"验证成功"];
    }else {
        
        self.errorCount ++;
        if (self.errorCount == 5) {
            
            [self savePassWord:nil];
            [self showAlertViewWith:@"密码错误超出限制，请重新登录并设置手势密码"];
            return;
        }
        
        [self.pswView showError];
        [self showTipsWith:[NSString stringWithFormat:@"密码错误，还剩%ld次机会", (5 - self.errorCount)] color:kErrorColor error:YES];
    }
}

- (void)showTipsWith:(NSString *)tips color:(UIColor *)color error:(BOOL)error {
    
    self.tipsLabel.text = tips;
    self.tipsLabel.textColor = color;
    if (error) {
        
        [self shakeAnimationForView:self.tipsLabel];
    }
}

#pragma mark - 存储密码

- (void)savePassWord:(NSString *)psw {
    
    [[NSUserDefaults standardUserDefaults] setObject:psw forKey:kPsw];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getPassWord {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPsw];
}

#pragma mark - 成功提示

- (void)showAlertViewWith:(NSString *)tips {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:tips
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                   }];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 抖动动画
- (void)shakeAnimationForView:(UIView *)view {
    
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES]; // 平滑结束
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
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
