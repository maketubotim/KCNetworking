//
//  SampleRequestModel.h
//  KCNetworking
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SampleRequestModel : NSObject

@property (nonatomic, copy) NSString *foo;

/** 第几页 */
@property (nonatomic, copy) NSNumber *pageNumber;
/** 页码 */
@property (nonatomic, copy) NSNumber *pageSize;

- (NSDictionary *)dictionaryValue;

@end
