//
//  QRModel.m
//  ScanDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import "QRModel.h"

@interface QRModel()<NSCopying>

@end

@implementation QRModel

-(id)initWithDic:(NSDictionary *)dic
{
    if(self)
    {
        self.title = [dic objectForKey:@"title"]?[dic objectForKey:@"title"]:@"";
        self.detail = [dic objectForKey:@"detail"]?[dic objectForKey:@"detail"]:@"";
        self.remark = [dic objectForKey:@"remark"]?[dic objectForKey:@"remark"]:@"0";
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    QRModel *model = [QRModel new];
    if(self)
    {
        model.title = self.title;
        model.detail = self.detail;
        model.remark = self.remark;
        return model;
    }
    else
    {
        model.title = @"";
        model.detail = @"";
        model.remark = @"0";
        return model;
    }
}

@end
