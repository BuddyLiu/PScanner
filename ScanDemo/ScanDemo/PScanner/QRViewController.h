//
//  QRViewController.h
//  QRWeiXinDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QRViewControllerDelegate <NSObject>

-(void)finishScanWithContent:(NSString *)scanContent;

@end

@interface QRViewController : UIViewController

@property (nonatomic, strong) id<QRViewControllerDelegate> delegate;

@end
