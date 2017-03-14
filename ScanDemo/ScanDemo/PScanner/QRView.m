//
//  QRView.m
//  QRWeiXinDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import "QRView.h"

static NSTimeInterval kQrLineanimateDuration = 0.02;

@implementation QRView
{
    UIImageView *qrLine;
    CGFloat qrLineY;
    QRMenu *qrMenu;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        qrLineY = self.frame.size.height / 2 - self.transparentArea.height /2;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!qrLine)
    {
        [self initQRLine];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kQrLineanimateDuration target:self selector:@selector(show) userInfo:nil repeats:YES];
        [timer fire];
    }
    if (!qrMenu)
    {
        [self initQrMenu];
    }
}

- (void)initQRLine
{
    qrLine  = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - self.transparentArea.width / 2, self.bounds.size.height / 2 - self.transparentArea.height / 2, self.transparentArea.width, 2)];
    qrLine.backgroundColor = [UIColor colorWithRed:83.0/255.0 green:239.0/255.0 blue:111.0/255.0 alpha:0.8];
    qrLine.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:qrLine];
    qrLineY = qrLine.frame.origin.y;
}

- (void)initQrMenu
{
    CGFloat height = 50;
    CGFloat width = self.bounds.size.width;
    qrMenu = [[QRMenu alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - height, width, height)];
    qrMenu.backgroundColor = [UIColor whiteColor];
    [self addSubview:qrMenu];
    
    __weak typeof(self)weakSelf = self;

    qrMenu.didSelectedBlock = ^(QRItem *item){
        if ([weakSelf.delegate respondsToSelector:@selector(scanTypeConfig:)] )
        {
            [weakSelf.delegate scanTypeConfig:item];
        }
    };
}

- (void)show
{
    [UIView animateWithDuration:kQrLineanimateDuration animations:^{
        
        CGRect rect = qrLine.frame;
        rect.origin.y = qrLineY;
        qrLine.frame = rect;
        
    } completion:^(BOOL finished) {
        
        //单程扫面动画
        CGFloat maxBorder = self.frame.size.height / 2 + self.transparentArea.height / 2 - 4;
        if(qrLineY > maxBorder)
        {
            qrLineY = self.frame.size.height / 2 - self.transparentArea.height / 2;
        }
        qrLineY++;
//        //往返扫描动画
//        CGFloat maxBorder = self.frame.size.height / 2 + self.transparentArea.height / 2 - 4;
//        CGFloat minBorder = self.frame.size.height / 2 - self.transparentArea.height / 2;
//        static BOOL direction = YES; //YES for down, NO for up.
//        if (qrLineY >= minBorder && qrLineY <= maxBorder && direction)
//        {
//            qrLineY++;
//        }
//        else
//        {
//            if(qrLineY > maxBorder)
//            {
//                direction = NO;
//            }
//            else if (qrLineY < minBorder)
//            {
//                direction = YES;
//                qrLineY++;
//                return;
//            }
//            qrLineY--;
//        }
    }];
}

- (void)drawRect:(CGRect)rect
{
    //整个二维码扫描界面的颜色
    CGSize screenSize =[UIScreen mainScreen].bounds.size;
    CGRect screenDrawRect =CGRectMake(0, 0, screenSize.width,screenSize.height);
    
    //中间清空的矩形框
    CGRect clearDrawRect = CGRectMake(screenDrawRect.size.width / 2 - self.transparentArea.width / 2,
                                      screenDrawRect.size.height / 2 - self.transparentArea.height / 2,
                                      self.transparentArea.width,self.transparentArea.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:screenDrawRect];
    
    [self addCenterClearRect:ctx rect:clearDrawRect];
    
    [self addWhiteRect:ctx rect:clearDrawRect];
    
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}

- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect
{
    //画四个边角
    CGContextSetLineWidth(ctx, 3);
    CGContextSetRGBStrokeColor(ctx, 83 /255.0, 239/255.0, 111/255.0, 1);//绿色
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + 15)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + 15 +0.7 )};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ -15),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15 , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx
{
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

@end
