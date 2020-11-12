#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KCCacheCenter.h"
#import "KCCacheProtocol.h"
#import "KCResponseError.h"
#import "KCRequest+Private.h"
#import "KCRequest.h"
#import "KCRequestDispatchCenter.h"
#import "KCRequestProtocol.h"
#import "KCResponse.h"
#import "KCNetworking.h"
#import "KCRequestConstants.h"
#import "KCRequestEnumrator.h"
#import "KCPromise.h"
#import "KCCacheRequest.h"
#import "KCSecurityPolicyAccessory.h"

FOUNDATION_EXPORT double KCNetworkingVersionNumber;
FOUNDATION_EXPORT const unsigned char KCNetworkingVersionString[];

