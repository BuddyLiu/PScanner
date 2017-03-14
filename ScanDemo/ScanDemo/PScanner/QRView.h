//
//  QRView.h
//  QRWeiXinDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRMenu.h"

@protocol QRViewDelegate <NSObject>

-(void)scanTypeConfig:(QRItem *)item;

@end

@interface QRView : UIView

@property (nonatomic, weak) id<QRViewDelegate> delegate;
/**
 *  透明的区域
 */
@property (nonatomic, assign) CGSize transparentArea;

@end
