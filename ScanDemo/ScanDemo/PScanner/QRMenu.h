//
//  QRMenu.h
//  QRWeiXinDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRItem.h"

typedef void(^QRMenuDidSelectedBlock)(QRItem *item);

@interface QRMenu : UIView

@property (nonatomic, copy) QRMenuDidSelectedBlock didSelectedBlock;

- (instancetype)initWithFrame:(CGRect)frame;

@end
