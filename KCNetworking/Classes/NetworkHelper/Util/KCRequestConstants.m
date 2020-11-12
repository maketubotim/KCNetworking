//
//  KCRequestConstants.m
//  KCRequest
//
//  Created by 鼎耀 on 2020/11/10.
//  Copyright © 2020 Linyoung. All rights reserved.
//

#include "KCRequestConstants.h"

void KCLog(NSString* format, ...)
{
#ifdef DEBUG
    va_list argptr;
    va_start(argptr, format);
    NSLogv(format, argptr);
    va_end(argptr);
#endif
}


void blockCleanUp(__strong void(^*block)(void)) {
    (*block)();
}
