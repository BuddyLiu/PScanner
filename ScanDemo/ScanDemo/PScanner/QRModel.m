//
//  QRModel.m
//  ScanDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import "QRModel.h"

@interface QRModel()<NSCopying, NSCoding>

@end

@implementation QRModel

-(id)initWithDic:(NSDictionary *)dic
{
    if(self)
    {
        self.QRTitle = [dic objectForKey:@"title"]?[dic objectForKey:@"title"]:@"";
        self.QRDetail = [dic objectForKey:@"detail"]?[dic objectForKey:@"detail"]:@"";
        self.QRRemark = [dic objectForKey:@"remark"]?[dic objectForKey:@"remark"]:@"0";
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    QRModel *model = [QRModel new];
    if(self)
    {
        model.QRTitle = self.QRTitle;
        model.QRDetail = self.QRDetail;
        model.QRRemark = self.QRRemark;
        return model;
    }
    else
    {
        model.QRTitle = @"";
        model.QRDetail = @"";
        model.QRRemark = @"0";
        return model;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self == [super init])
    {
        self.QRTitle = [aDecoder decodeObjectForKey:@"title"];
        self.QRDetail = [aDecoder decodeObjectForKey:@"detail"];
        self.QRRemark = [aDecoder decodeObjectForKey:@"remark"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.QRTitle forKey:@"title"];
    [aCoder encodeObject:self.QRDetail forKey:@"detail"];
    [aCoder encodeObject:self.QRRemark forKey:@"remark"];
}
@end
