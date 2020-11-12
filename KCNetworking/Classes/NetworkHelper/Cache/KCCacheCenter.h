//
//  KCCacheCenter.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCCacheProtocol.h"
@class KCResponse;

@interface KCCacheCenter : NSObject<KCCacheProtocol>

+ (id)defultCenter;

@end
