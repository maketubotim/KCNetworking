//
//  KCPromise.m
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#import "KCPromise.h"
#include "KCRequestConstants.h"

typedef KCPromise*(^KCPromiseWorkEventHandler)();

@interface KCPromise()

@property (nonatomic, strong) id data;
@property (nonatomic, weak  ) KCPromise *resolver;//resolver回调,then中的第一个参数
@property (nonatomic, assign) BOOL called;

@property (nonatomic, assign) KCPromiseResoverStatus status;
@property (nonatomic, strong) NSMutableArray *fulfillQueue;
@property (nonatomic, strong) NSMutableArray *rejectQueue;

@end


@implementation KCPromise


#pragma mark - Lifecycle

- (void)dealloc {
//    NSLog(@"promise dealloc %p", self);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.status = KCPromiseResoverStatusPending;
        self.fulfillQueue = [NSMutableArray arrayWithCapacity:0];
        self.rejectQueue  = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}


+ (KCPromise *)promise {
    KCPromise *promise = [[KCPromise alloc] init];
    [promise setup];
    return promise;
}

/**
 *  bind chain
 *
 *  @return a promise node of resover chian
 */
- (KCPromise *)chainNodePromiseWithResover:(KCPromise *)resolver {
    KCPromise *promise = [[KCPromise alloc] init];
    promise.resolver = resolver?:self;
    [promise setup];
    return promise;
}


- (void)setup {

    __weak __typeof(self) weakSelf = self;
    
    self.then = ^id(KCPromiseEventHandler onFulfilled,KCPromiseEventHandler onRejected) {
        __strong __typeof(weakSelf) self = weakSelf;
        return [self then:onFulfilled onRejected:onRejected];
    };

    self.next = ^id(KCPromiseEventHandler onFulfilled) {
        __strong __typeof(weakSelf) self = weakSelf;
        return [self next:onFulfilled];
    };
    
    self.catch = ^KCPromise*(void(^onRejected)(id reason)) {
        __strong __typeof(weakSelf) self = weakSelf;

        id(^warpedOnRejected)(id reason) = ^id(id reason) {
            KCPromiseWorkEventHandler work = ^id(){
                onRejected(reason);
                return nil;
            };
            return work();
        };
        
        KCPromise *resolver = self.resolver?:self;

        [self addListener:KCPromiseResoverStatusRejected callback:warpedOnRejected];
        
        [resolver addListener:KCPromiseResoverStatusRejected callback:warpedOnRejected];
        
        return self;
    };
}

#pragma mark - Action

- (KCPromise *)then:(KCPromiseEventHandler)onFulfilled
         onRejected:(KCPromiseEventHandler)onRejected {
    
    KCPromise *promise = [self chainNodePromiseWithResover:self.resolver];
    
    __weak __typeof(self) weakPromise = promise;
    if (onFulfilled) {
        onFulfilled = [KCPromise wrapPromise:promise callback:onFulfilled];
    } else {
        onFulfilled = ^id(id data) {
            __strong __typeof(weakPromise) promise = weakPromise;
            return [promise fulfill:data];
        };
    }
    [self addListener:KCPromiseResoverStatusFulfilled callback:onFulfilled];
    
    if (onRejected) {
        onRejected = [KCPromise wrapPromise:promise callback:onRejected];
    } else {
        onRejected = ^id(id reason) {
            __strong __typeof(weakPromise) promise = weakPromise;
            return [promise reject:reason];
        };
    }
    [self addListener:KCPromiseResoverStatusRejected callback:onRejected];
    
//    onExit {
        if (self.run) {
            self.run();
        }
//    };

    return promise;
}

- (KCPromise *)next:(KCPromiseEventHandler)onFulfilled {
    
    KCPromise *promise = [self chainNodePromiseWithResover:self.resolver];
    
    __weak __typeof(self) weakPromise = promise;
    if (onFulfilled) {
        onFulfilled = [KCPromise wrapPromise:promise callback:onFulfilled];
    } else {
        onFulfilled = ^id(id data) {
            __strong __typeof(weakPromise) promise = weakPromise;
            return [promise fulfill:data];
        };
    }
    
    [self addListener:KCPromiseResoverStatusFulfilled callback:onFulfilled];
    
    [self addListener:KCPromiseResoverStatusRejected callback:^id(id reason) {
//#warning Need Warp
        __strong __typeof(weakPromise) promise = weakPromise;
        KCPromise *resover = promise.resolver;
        if (resover && resover.status == KCPromiseResoverStatusFulfilled) {
            resover.status = KCPromiseResoverStatusPending;
        }
        return [resover reject:reason];
    }];
    //在它的作用域结束时可以自动执行一个指定的方法
    onExit {
        if (self.run) {
            self.run();
        }
    };
    
    return promise;
}

/**
 *  In Queue
 *
 *  @param callback
 */
- (void)addListener:(KCPromiseResoverStatus)status callback:(KCPromiseEventHandler)callback {
    if (self.status == status) {
        callback(self.data);
    } else if (status == KCPromiseResoverStatusFulfilled) {
        [self.fulfillQueue insertObject:callback atIndex:0];
    } else if (status == KCPromiseResoverStatusRejected) {
        [self.rejectQueue insertObject:callback atIndex:0];
    }
}

- (id)reject:(id)reason{
    if (self.status != KCPromiseResoverStatusPending) {
        return nil;
    }
    self.data = reason;
    self.status = KCPromiseResoverStatusRejected;
    return [self emit];
}

- (id)fulfill:(id)data{
    if (self.status != KCPromiseResoverStatusPending) {
        return nil;
    }
    self.data = data;
    self.status = KCPromiseResoverStatusFulfilled;
    return [self emit];
}

/**
 *  Emit all callbacks but only return the first promise object
 *
 *  @return promise object
 */

- (id)emit {
    
    NSMutableArray *items = self.status == KCPromiseResoverStatusFulfilled?self.fulfillQueue:self.rejectQueue;
    
    if (!items.count) {
        return nil;
    }
    
    KCPromiseEventHandler callback = items.lastObject;
    for (int i = 0; i < items.count-1; i++) {
        KCPromiseEventHandler callback = items[i];
        callback(self.data);
    }
    
    onExit {
        [items removeAllObjects];
    };
    
    return callback(self.data);
    
}


+ (KCPromiseEventHandler)wrapPromise:(KCPromise *)promise
                            callback:(KCPromiseEventHandler)callback {
    
    return ^id(id data) {
        KCPromiseWorkEventHandler work = ^id(){
            id res = callback(data);
            if (res == promise) {
                return [KCPromise rejected];
            }
            return [KCPromise resolve:promise value:res];
        };
        return work();
    };
}

+ (KCPromiseEventHandler)wrapResover:(KCPromise *)resolver
                            callback:(KCPromiseEventHandler)callback {
    return ^id(id data) {
        KCPromiseWorkEventHandler work = ^id(){
            id res = callback(data);
            if (res == resolver) {
                return [KCPromise rejected];
            }
            return res;
        };
        return work();
    };
}


/**
 *
 *  @param promise promise
 *  @param value    promise or data
 *
 *  @return next promise or data
 */
+ (id)resolve:(KCPromise *)promise value:(KCPromise *)value {
    
    __weak __typeof(promise) weakPromise = promise;
    __weak __typeof(value) weakValue = value;
    
    KCPromiseEventHandler onFulfilled = ^id(id data) {
        if (promise && !promise.called) {
            promise.called = YES;
            return [KCPromise resolve:promise value:data];
        }
        return [KCPromise fulfilled];
    };
    
    KCPromiseEventHandler onRejected = ^id(id reason) {
        
        if (promise && !promise.called) {
            promise.called = YES;
            return [promise reject:reason];
        }
        return [KCPromise rejected];
    };
    
    KCPromiseWorkEventHandler work = ^id(){
        __strong __typeof(weakPromise) promise = weakPromise;
        __strong __typeof(weakValue) value = weakValue;
        
        if ([value isKindOfClass:KCPromise.class] && [value respondsToSelector:@selector(then)]) {
            return value.then(onFulfilled, onRejected);
        } else {
            return [promise fulfill:value];
        }
    };
    
    return work();
}

+ (KCPromise *)all:(NSArray<KCPromise *> *)promises {
    
    KCPromise *resolver = [KCPromise promise];
    
    __block NSInteger resolvedCount = 0;
    
    NSMutableDictionary *resultHash = [NSMutableDictionary dictionaryWithCapacity:promises.count];
    
    KCPromiseEventHandler(^createResolvedHandler)(NSInteger) = ^KCPromiseEventHandler(NSInteger index) {
        __block NSInteger captureIndex = index;
        return ^id(id data) {
            [resultHash setObject:data forKey:_S(@"%zd",captureIndex)];
            if (++resolvedCount >= promises.count) {
                NSArray *keys = [[resultHash allKeys] sortedArrayUsingSelector:@selector(compare:)];
                NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
                for (NSString *key in keys) {
                    [resultArray addObject:resultHash[key]];
                }
                return [resolver fulfill:resultArray];
            }
            return nil;
        };
    };
    
    [promises enumerateObjectsUsingBlock:^(KCPromise * _Nonnull promise, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([KCPromise isKindOfClass:KCPromise.class], @"require instance of KCPromise");
        
        KCPromiseEventHandler rejectedHandler = ^id(id reason) {
            for (KCPromise *object in promises) {
                if (object != promise) {
                    object.done();
                }
            }
            return [resolver reject:reason];
        };
        
        promise.then(createResolvedHandler(idx), rejectedHandler);
    }];
    
    return resolver;
}

+ (KCPromise *)fulfilled {
    KCPromise *promise = [KCPromise promise];
    promise.status = KCPromiseResoverStatusFulfilled;
    return promise;
}

+ (KCPromise *)rejected {
    KCPromise *promise = [KCPromise promise];
    promise.status = KCPromiseResoverStatusRejected;
    return promise;
}

#pragma mark - Getter

- (dispatch_block_t)done {
    if (!_done) {
        __weak __typeof(self) weakSelf = self;
        _done = [^() {
            __strong __typeof(weakSelf) self = weakSelf;
            self.status = KCPromiseResoverStatusFulfilled;
        } copy];
    }
    return _done;
}

@end

