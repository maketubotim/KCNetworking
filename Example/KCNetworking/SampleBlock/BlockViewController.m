//
//  BlockViewController.m
//  KCNetworking_Example
//
//  Created by 鼎耀 on 2020/11/12.
//  Copyright © 2020 maketubotim. All rights reserved.
//

#import "BlockViewController.h"
#import "CaculateMaker.h"

//typedef简化Block的声明
typedef void (^ClickBlock)(NSInteger index);
typedef void (^handleBlock)();

@interface BlockViewController ()

//例子1：作属性,block属性
@property(nonatomic,copy) ClickBlock imageClickBlock;

@property (nonatomic, assign) CGFloat result;

@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

/*
 约定：用法中的符号含义列举如下：
 return_type 表示返回的对象/关键字等(可以是void，并省略)
 blockName 表示block的名称
 var_type 表示参数的类型(可以是void，并省略)
 varName 表示参数名称
*/

- (void)block{
//    (1) 标准声明与定义
//    return_type (^blockName)(var_type) = ^return_type (var_type varName) {
//        // ...
//    };
//    blockName(var);
//
//    (2) 当返回类型为void
//    void (^blockname)(int a) = ^void (int a){
//
//    };
//    blockname(1);
//    可省略写成
//    void (^blockname) (int a) = ^(int a){
//
//    };
//    (3) 当参数类型为void
//    void (^blockname)(void) = ^void (void){
//
//    };
//    可省略写成
//    void (^blockname)(void) = ^void (){
//
//    };
//    (4) 当返回类型和参数类型都为void
//    void (^blockname)(void) = ^void (void){
//
//    };
//    可省略写成
//    void (^blockname)(void) = ^{
//
//    };
//    (5) 匿名Block,Block实现时，等号右边就是一个匿名Block，它没有blockName，称之为匿名Block
//    ^void (int a){
//
//    };
}

//例子2：作方法参数
- (void)requestForTestBlockHandle:(handleBlock)handle{
    
}
//在定义方法时，声明Block型的形参
- (void)addClickedBlock:(void(^)(id objc))clickAction{
    
}

//2.4 Block的少见用法
//2.4.1 Block的内联用法
//这种形式并不常用，匿名Block声明后立即被调用：
//^return_type (var_type varName)
//{
//    //...
//}(var);

//2.4.2 Block的递归调用
//__block return_type (^blockName)(var_type) = [^return_type (var_type varName)
//{
//    if (returnCondition)
//    {
//        blockName = nil;
//        return;
//    }
//    // ...
//    // 【递归调用】
//    blockName(varName);
//} copy];
//
//【初次调用】
//blockName(varValue);

//2.4.3 Block作为返回值
//
//方法的返回值是一个Block，可用于一些“工厂模式”的方法中：

//- (return_type(^)(var_type))methodName
//{
//    return ^return_type(var_type param) {
//        // ...
//    };
//}

//3. Block应用场景
//
//3.1 响应事件

//3.2 传递数据---传递数值,传递对象

//3.3 链式语法
- (void)blockChain{
    CaculateMaker *maker = [[CaculateMaker alloc] init];
    maker.add(20).add(30);
    NSLog(@"%f",maker.result);
}

//4.5 所有的Block里面的self必须要weak一下？
//有些情况下是可以直接使用self的，比如调用系统的方法
//[UIView animateWithDuration:0.5 animations:^{
//        NSLog(@"%@", self);
//}];

//看mas_makexxx的方法实现会发现这个block很快就被调用了，完事儿就出栈销毁，构不成循环引用，所以可以直接放心的使self。另外，这个与网络请求里面使用self道理是一样的
//[self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.centerY.equalTo(self.otherView.mas_centerY);
//}];

@end
