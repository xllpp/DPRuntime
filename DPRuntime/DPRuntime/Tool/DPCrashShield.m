//
//  DPCrashShield.m
//  DiamondPark
//
//  Created by 麻小亮 on 2019/4/15.
//  Copyright © 2019 DiamondPark. All rights reserved.
//

#import "DPCrashShield.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <pthread.h>
#import "DPRuntimeTool.h"

@implementation NSObject(DPCrashShield)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [DPCrashShield start];
    });
}

@end

@implementation DPCrashShield

+ (void)start{
    [self dpUICrashShield];
    [self dpContainerShield];
}

+ (void)dpUICrashShield{
    NSArray *sels= @[@"setNeedsLayout",@"setNeedsDisplay",@"setNeedsDisplayInRect:", @"setNeedsUpdateConstraints"];
    for (NSString *selString in sels) {
        [DPRuntimeTool swizzingWithClass:objc_getClass("UIView") sel:NSSelectorFromString(selString) withOptions:DPRuntimeMethodSwizzleOptionsBefore block:^(id object, SEL sel, DPRuntimeMethodSwizzleOptions options, DPTuple *tuple, BOOL *stop) {
            
        } performBlock:^(DPBlock perform, id object, SEL sel) {
            if ([NSThread currentThread].isMainThread) {
                perform();
            }else{
                NSLog(@"对象：：：： %@ 方法：：：  %@ 不在主线程", object, NSStringFromSelector(sel));
                dispatch_async(dispatch_get_main_queue(), ^{
                    perform();
                });
            }
        }];
    }
}




+ (void)dpContainerShield{
    Class class = objc_getClass("__NSArrayM");
    [DPRuntimeTool swizzingWithClass:class sel:@selector(addObject:) withOptions:DPRuntimeMethodSwizzleOptionsBefore block:^(id object, SEL sel, DPRuntimeMethodSwizzleOptions options, DPTuple *tuple, BOOL *stop) {
        if (tuple.first == nil) {
            *stop = YES;
        }
    }];
    [DPRuntimeTool swizzingWithClass:class sel:@selector(insertObject:atIndex:) withOptions:DPRuntimeMethodSwizzleOptionsBefore block:^(id object, SEL sel, DPRuntimeMethodSwizzleOptions options, DPTuple *tuple, BOOL *stop) {
        if (tuple.first == nil) {
            *stop = YES;
        }
    }];
    [DPRuntimeTool swizzingWithClass:class sel:@selector(addObject:) withOptions:DPRuntimeMethodSwizzleOptionsBefore block:^(id object, SEL sel, DPRuntimeMethodSwizzleOptions options, DPTuple *tuple, BOOL *stop) {
        if (tuple.first == nil) {
            *stop = YES;
        }
    }];
    [DPRuntimeTool swizzingWithClass:class sel:@selector(objectAtIndex:) withOptions:DPRuntimeMethodSwizzleOptionsBefore block:^(id object, SEL sel, DPRuntimeMethodSwizzleOptions options, DPTuple *tuple, BOOL *stop) {
        if ([tuple.first integerValue] >= [object count]) {
            *stop = YES;
        }
    }];
    

}

+ (void)dpArrayShield:(Class)clas{
    
}
@end
