//
//  MonitorUtil.m
//  OnlinePerformanceMonitor
//
//  Created by xiaoshuang on 2019/8/26.
//  Copyright © 2019年 xiaoshuang. All rights reserved.
//

#import "MonitorUtil.h"
#import <Foundation/Foundation.h>
#include <sys/sysctl.h>
#include <mach/mach.h>
#import <QuartzCore/QuartzCore.h>
#include <mach/task_info.h>

@interface MonitorUtil (){
    CADisplayLink *_link;
    NSTimeInterval _lastTime;
    float _fps;
}
@property (nonatomic, assign) int count;

@end

@implementation MonitorUtil
static MonitorUtil *_monitor = nil;

+ (instancetype)shareMonitorUtil {
    if (_monitor == nil) {
        _monitor = [[self alloc] init];
    }
    return _monitor;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _monitor = [super allocWithZone:zone];
    });
    return _monitor;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

- (integer_t)cpuUsage {
    thread_act_array_t threads; //int 组成的数组比如 thread[1] = 5635
    mach_msg_type_number_t threadCount = 0; //mach_msg_type_number_t 是 int 类型
    const task_t thisTask = mach_task_self();
    //根据当前 task 获取所有线程
    kern_return_t kr = task_threads(thisTask, &threads, &threadCount);
    
    if (kr != KERN_SUCCESS) {
        return 0;
    }
    
    integer_t cpuUsage = 0;
    // 遍历所有线程
    for (int i = 0; i < threadCount; i++) {
        
        thread_info_data_t threadInfo;
        thread_basic_info_t threadBaseInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
        
        if (thread_info((thread_act_t)threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
            // 获取 CPU 使用率
            threadBaseInfo = (thread_basic_info_t)threadInfo;
            if (!(threadBaseInfo->flags & TH_FLAGS_IDLE)) {
                cpuUsage += threadBaseInfo->cpu_usage;
            }
        }
    }
    assert(vm_deallocate(mach_task_self(), (vm_address_t)threads, threadCount * sizeof(thread_t)) == KERN_SUCCESS);
    return cpuUsage;
}

- (void)startMonitoring {
    if (_link) {
        [_link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_link invalidate];
        _link = nil;
    }
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(fpsDisplayLinkAction:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)fpsDisplayLinkAction:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    self.count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    _fps = _count / delta;
    NSLog(@"count = %d, delta = %f,_lastTime = %f, _fps = %.0f",_count, delta, _lastTime, _fps);
    self.count = 0;
}

- (unsigned long)memoryUsage {    
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (result != KERN_SUCCESS)
        return 0;
    return vmInfo.phys_footprint;
}

@end
