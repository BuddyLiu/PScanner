//
//  QRModel.h
//  ScanDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRModel : NSObject

@property (nonatomic, copy) NSString *QRTitle;
@property (nonatomic, copy) NSString *QRDetail;
@property (nonatomic, copy) NSString *QRRemark;

-(id)initWithDic:(NSDictionary *)dic;

@end
