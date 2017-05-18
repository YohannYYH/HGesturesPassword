//
//  HGesturesPasswordView.m
//  HGesturesPassword
//
//  Created by yyh on 2017/5/17.
//  Copyright © 2017年 yyh. All rights reserved.
//

#define kTime        .5                   //图像清空时间
#define kLineWidth   2                    //线条宽度

#import "HGesturesPasswordView.h"

@interface HGesturesPasswordView ()

@property (strong, nonatomic) NSMutableArray *points;
@property (strong, nonatomic) NSMutableArray *selectPoints;
@property (assign, nonatomic) BOOL resultView;
@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) CGFloat space;
@property (assign, nonatomic) BOOL error;

@property (assign, nonatomic) CGPoint currentPoint;
@property (copy, nonatomic) returnBlock block;

@end

@implementation HGesturesPasswordView

- (instancetype)initWithFrame:(CGRect)frame resultView:(BOOL)resultView block:(returnBlock)block {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectPoints = [NSMutableArray arrayWithCapacity:0];
        
        self.block = block;
        self.resultView = resultView;
        self.radius = frame.size.width / 10;
        self.space = self.radius;
    }
    
    return self;
}

- (NSMutableArray *)points {
    
    if (!_points) {
        
        _points = [NSMutableArray arrayWithCapacity:0];
        
        for (int i = 0; i < 9; i ++) {
            
            CGFloat x = self.radius * 2 + (self.radius * 2 + self.space) * (i % 3);
            CGFloat y = self.radius * 2 + (self.radius * 2 + self.space) * (i / 3);
            
            CGPoint point = CGPointMake(x, y);
            NSValue *value = [NSValue valueWithCGPoint:point];
            
            [_points addObject:value];
        }
    }
    
    return _points;
}

- (void)drawRect:(CGRect)rect {
    
    for (int i = 0; i < self.points.count; i ++) {
        
        UIBezierPath *arcNormerPath = [UIBezierPath bezierPathWithArcCenter:[self.points[i] CGPointValue] radius:self.radius startAngle:0 endAngle:M_PI * 2 clockwise:NO];
        [arcNormerPath setLineWidth:1];
        
        NSValue *value = self.points[i];
        if ([self.selectPoints containsObject:value]) {
            
            [[self color] setFill];
            [[self color] setStroke];
            
            if (self.resultView) {
                
                [[UIBezierPath bezierPathWithArcCenter:[value CGPointValue] radius:self.radius / 3 startAngle:0 endAngle:M_PI * 2 clockwise:NO] fill];
            }else {
                
                [[UIBezierPath bezierPathWithArcCenter:[value CGPointValue] radius:self.radius startAngle:0 endAngle:M_PI * 2 clockwise:NO] fill];
            }
            
        }else {
            
            [kNormalColor setStroke];
        }
        
        [arcNormerPath stroke];
    }
    
    if (self.selectPoints.count == 0) return;
    if (!self.resultView) return;
    
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    [linePath setLineWidth:kLineWidth];
    [linePath moveToPoint:[self.selectPoints[0] CGPointValue]];
    
    for (int i = 0; i < self.selectPoints.count; i ++) {
        
        if (i > 0) {
            
            [linePath addLineToPoint:[self.selectPoints[i] CGPointValue]];
        }
    }
    
    if (!CGPointEqualToPoint(CGPointZero, self.currentPoint)) {
        
        [linePath addLineToPoint:self.currentPoint];
    }
    
    [[self color] setStroke];
    [linePath stroke];
}

#pragma mark - 
#pragma mark touchs

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self reset];
    
    UITouch *touch = [touches anyObject];
    if (!touch) return;
        
    CGPoint point = [touch locationInView:self];
    
    for (int i = 0; i < self.points.count; i ++) {
        
        NSValue *value = self.points[i];
        if ([self compareLocationWithPoint:[value CGPointValue] movePoint:point]) {
            
            [self.selectPoints addObject:value];
            self.currentPoint = [value CGPointValue];
            [self setNeedsDisplay];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    if (!touch) return;

    CGPoint point = [touch locationInView:self];
    self.currentPoint = point;
    
    for (int i = 0; i < self.points.count; i ++) {
        
        NSValue *value = self.points[i];
        if ([self compareLocationWithPoint:[value CGPointValue] movePoint:point] && ![self.selectPoints containsObject:value]) {
            
            [self.selectPoints addObject:value];
            self.currentPoint = [value CGPointValue];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self getPsw];
    
    for (int i = 0; i < self.selectPoints.count; i ++) {
        
        NSValue *value = self.selectPoints[i];
        if (![self compareLocationWithPoint:[value CGPointValue] movePoint:self.currentPoint]) {
            
            self.currentPoint = [[self.selectPoints lastObject] CGPointValue];
        }
    }
    
    if (self.selectPoints.count < 4) {
        
        self.error = YES;
        [self performSelector:@selector(reset) withObject:nil afterDelay:kTime];
        
    }else {
        
        [self performSelector:@selector(reset) withObject:nil afterDelay:kTime];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self reset];
}

#pragma mark -

- (BOOL)compareLocationWithPoint:(CGPoint)point movePoint:(CGPoint)movePoint {
    
    CGFloat xDif = fabs(point.x - movePoint.x);
    CGFloat yDif = fabs(point.y - movePoint.y);
    
    if (xDif < self.radius && yDif < self.radius ) {
        
        return YES;
    }
    
    return NO;
}

- (UIColor *)color {
    
    return self.error ? kErrorColor : kSelectColor;
}

- (void)getPsw {
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < self.selectPoints.count; i ++) {
        
        NSValue *value = self.selectPoints[i];
        NSInteger index = [self.points indexOfObject:value];
        
        [resultArray addObject:@(index)];
    }
    
    if (self.block) {
        
        self.block(resultArray);
    }
}

- (void)reset {
    
    [self.selectPoints removeAllObjects];
    self.error = NO;
    self.currentPoint = CGPointMake(0, 0);
    [self setNeedsDisplay];
}

- (void)showResultWith:(NSMutableArray *)array {
    
    [self reset];
    
    for (int i = 0; i < array.count; i ++) {
        
        NSNumber *num = array[i];
        NSInteger index = [num integerValue];
        [self.selectPoints addObject:self.points[index]];
    }
    
    [self setNeedsDisplay];
    [self performSelector:@selector(reset) withObject:nil afterDelay:kTime];
}

- (void)showError {
    
    self.error = YES;
    [self setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
