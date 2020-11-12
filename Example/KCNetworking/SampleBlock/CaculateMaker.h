//
//  CaculateMaker.h
//  KCNetworking_Example
//
//  Created by 鼎耀 on 2020/11/12.
//  Copyright © 2020 maketubotim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CaculateMaker : NSObject
/*
 链式编程思想：核心思想为将block作为方法的返回值，且返回值的类型为调用者本身，并将该方法以setter的形式返回，这样就可以实现了连续调用，即为链式编程
*/
@property (nonatomic, assign) CGFloat result;

- (CaculateMaker *(^)(CGFloat num))add;

@end

NS_ASSUME_NONNULL_END
