//
//  QRMenu.m
//  QRWeiXinDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import "QRMenu.h"

@implementation QRMenu

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupQRItem];
    }
    return self;
}

- (void)setupQRItem
{
    QRItem *qrItem = [[QRItem alloc] initWithFrame:(CGRect){
        .origin.x = 0,
        .origin.y = 0,
        .size.width = self.bounds.size.width / 2,
        .size.height = self.bounds.size.height
    } titile:NSLocalizedString(@"QRCodeScan", @"二维码扫描按钮")];
    qrItem.type = QRItemTypeQRCode;
    [self addSubview:qrItem];
    
    QRItem *otherItem = [[QRItem alloc] initWithFrame: (CGRect){
        
        .origin.x = self.bounds.size.width / 2,
        .origin.y = 0,
        .size.width = self.bounds.size.width / 2,
        .size.height = self.bounds.size.height
    } titile:NSLocalizedString(@"BarCodeScan", @"条形码扫描按钮")];
    otherItem.type = QRItemTypeOther;
    [self addSubview:otherItem];
    
    [qrItem addTarget:self action:@selector(qrScan:) forControlEvents:UIControlEventTouchUpInside];
    [otherItem addTarget:self action:@selector(qrScan:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Action
- (void)qrScan:(QRItem *)qrItem
{
    if (self.didSelectedBlock)
    {
        self.didSelectedBlock(qrItem);
    }
}
@end
