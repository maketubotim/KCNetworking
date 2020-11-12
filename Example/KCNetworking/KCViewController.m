//
//  KCViewController.m
//  KCNetworking
//
//  Created by maketubotim on 06/23/2020.
//  Copyright (c) 2020 maketubotim. All rights reserved.
//

#import "KCViewController.h"
#import "Samples.h"
#import "SampleRequestModel.h"
#import "KCCacheCenter.h"

@interface KCViewController ()<KCRequestAccessory>

@end

@implementation KCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self testNext];
//    [self testThen];
//    [self testAll];
    [self testNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testThen
{
    //开始第一个异步任务
    SamplePHPRequest.promise.then(^id(id data){
        //获取第一个数据的返回结果
        //开始第二个异步任务
        return SamplePHPRequest.promise;
        
    },^id(KCResponseError *reason){
        
        //捕获第一个任务的异常
        //即使发生异常也会开始下一个任务, 并且向下一个任务(第三个)传入 reason
        return reason;
        
    }).then(^id(id bar){
        
        //获取上一个任务的返回结果
        //开始第三个任务(后续没有Promise任务, 将不会处理这个异步任务的返回数据)
        
        SampleRequestModel *model = [SampleRequestModel new];
        model.foo = bar;
        return [[[SamplePHPRequest new] bindRequestArgument:model] promise];
        
    },NULL);
}

- (void)testNext
{
    SamplePHPRequest.promise.next(^id(id data) {
        
        //处理第一个请求的response 并将处理结果传入下一个promise
        KCLogInfo(@"%@",data);
        return data;
        
    }).next(^id(id data){
        
        //获取上一个promise的处理结果
        //开始下一个网络请求
        
        return SamplePHPRequest.promise;
        
    }).next(^id(id data) {
        
        //处理第二个请求的response
        
        KCLogInfo(@"任务链完成");
        return data;
        
    }).catch(^(KCResponseError *reason) {
        
        //捕获整个promis链上的异常(发生一个异常就会结束promise任务链)
        
        KCLogError(@"任务链失败: %@",reason);
    });
}

- (void)testAll
{
    [KCPromise all:@[SampleRequest.promise, SamplePHPRequest.promise]].then(^id(id data) {
        
        //任务蔟都完成后调用逻辑
        KCLogInfo(@"获得数据: %@",data);
        return KCPromise.fulfilled;
        
    }, ^id(KCResponseError *reason) {
        
        //捕获整个任务簇的异常(发生一个异常就会结束所有任务)
        KCLogError(@"捕获异常: %@",reason);
        return KCPromise.rejected;
        
    });
}

- (void)testNormal
{
    SampleRequestModel *model = [SampleRequestModel new];
    model.pageNumber = [NSNumber numberWithInt:1];
    model.pageSize =  [NSNumber numberWithInt:10];
    SamplePHPRequest *request = [SamplePHPRequest new];
    request.requestArgument = model;
    [[request requestWithSuccess:^(id result, KCRequest *request) {
        KCLogInfo(@"");
    } failure:^(KCResponseError *error, KCRequest *request) {
        KCLogInfo(@"Cancel后将不会调用回调函数");
    }] appendAccessory:self];
//    id response = [[KCCacheCenter defultCenter] getCacheForRequest:request];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [request cancel];
//    });


}

@end
