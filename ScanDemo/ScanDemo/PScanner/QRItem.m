//
//  QRItem.m
//  QRWeiXinDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import "QRItem.h"
#import <objc/runtime.h>

@implementation QRItem

- (instancetype)initWithFrame:(CGRect)frame titile:(NSString *)titile
{
    self =  [QRItem buttonWithType:UIButtonTypeSystem];
    if (self)
    {
        [self setTitle:titile forState:UIControlStateNormal];
        self.frame = frame;
    }
    return self;
}
@end
