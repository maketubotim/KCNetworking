//
//  CaculateMaker.m
//  KCNetworking_Example
//
//  Created by 鼎耀 on 2020/11/12.
//  Copyright © 2020 maketubotim. All rights reserved.
//

#import "CaculateMaker.h"

@implementation CaculateMaker

- (CaculateMaker *(^)(CGFloat num))add{
    return ^CaculateMaker *(CGFloat num){
        _result += num;
        return self;
    };
}

@end
