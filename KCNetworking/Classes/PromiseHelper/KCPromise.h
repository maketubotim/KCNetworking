//
//  KCPromise.h
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//
/*
 Promise是异步编程的一种解决方案：从语法上讲，promise是一个对象，从它可以获取异步操作的消息；从本意上讲，它是承诺，承诺它过一段时间会给你一个结果。promise有三种状态： pending(等待态)，fulfiled(成功态)，rejected(失败态)；状态一旦改变，就不会再变。创造promise实例后，它会立即执行;
 promise是用来解决两个问题的：
 回调地狱，代码难以维护， 常常第一个的函数的输出是第二个函数的输入这种现象
 promise可以支持多个并发的请求，获取并发请求中的数据
 这个promise可以解决异步的问题，本身不能说promise是异步的
 Promise的精髓是“状态”，用维护状态、传递状态的方式来使得回调函数能够及时调用
*/

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KCPromiseResoverStatus) {
    KCPromiseResoverStatusPending,//等待态
    KCPromiseResoverStatusFulfilled,//成功态
    KCPromiseResoverStatusRejected//失败态
};

typedef id(^KCPromiseEventHandler)(id);

/**
 *  Class KCPromise
 */

@interface KCPromise : NSObject
/*
 链式编程思想：核心思想为将block作为方法的返回值，且返回值的类型为调用者本身，并将该方法以setter的形式返回，这样就可以实现了连续调用，即为链式编程
*/
//then 链式操作
@property (nonatomic, copy) KCPromise*(^then)(KCPromiseEventHandler,KCPromiseEventHandler);

@property (nonatomic, copy) KCPromise*(^next)(KCPromiseEventHandler);

//不能放在链首,catch方法，和then的第二个参数一样，用来指定reject的回调,它还有另外一个作用：在执行resolve的回调（也就是上面then中的第一个参数）时，如果抛出异常了（代码出错了），那么并不会报错卡死js，而是会进到这个catch方法中
@property (nonatomic, copy) KCPromise*(^catch)(void(^)(id reason));
//队列操作
@property (nonatomic, copy) dispatch_block_t done;

@property (nonatomic, copy) dispatch_block_t run;

//all的用法：谁跑的慢，以谁为准执行回调。all接收一个数组参数，里面的值最终都算返回Promise对象
+ (KCPromise *)all:(NSArray<KCPromise *> *)promises;

+ (KCPromise *)promise;

+ (KCPromise *)fulfilled;

+ (KCPromise *)rejected;

- (id)fulfill:(id)data;

- (id)reject:(id)reason;

@end
