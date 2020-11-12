//
//  CCSecurityPolicyAccessory.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "AFSecurityPolicy.h"
#import "KCRequestProtocol.h"

/**
 *  自签名证书 HTTPS 双向认证
 *
 *  自行更改:
 *      由CA签发的含有服务器公钥的数字证书
 *      由CA签发的含有客户端公钥的数字证书
 *      客户端私钥
 *  
 *  使用方法:
 *      调用KCRequest的实例方法
 *      - (KCRequest *)appendAccessory:(id<KCRequestAccessory>)accessory;
 *      并将defaultAccessory加入Accessory队列中
 */

@interface KCSecurityPolicyAccessory : NSObject <KCRequestAccessory>

+ (KCSecurityPolicyAccessory *)defaultAccessory;

@end
