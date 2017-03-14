//
//  QRItem.h
//  QRWeiXinDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QRItemType) {
    QRItemTypeQRCode = 0,
    QRItemTypeOther,
};

@interface QRItem : UIButton

@property (nonatomic, assign) QRItemType type;

- (instancetype)initWithFrame:(CGRect)frame titile:(NSString *)titile;
@end
