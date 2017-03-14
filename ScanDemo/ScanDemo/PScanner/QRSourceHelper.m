//
//  QRSourceHelper.m
//  IdealMobileOffice
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import "QRSourceHelper.h"

@implementation QRSourceHelper

static QRSourceHelper *sharedService = nil;

+(QRSourceHelper *)sharedService
{
    if (!sharedService)
    {
        sharedService = [[QRSourceHelper alloc]init];
    }
    return sharedService;
}

@end
