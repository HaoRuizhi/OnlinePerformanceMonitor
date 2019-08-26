//
//  ViewController.m
//  OnlinePerformanceMonitor
//
//  Created by xiaoshuang on 2019/8/26.
//  Copyright © 2019年 xiaoshuang. All rights reserved.
//

#import "ViewController.h"
#import "MonitorUtil.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSTimer *timer = [NSTimer timerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"CPU使用率为 %d memory 使用率为 %ld", [[MonitorUtil shareMonitorUtil] cpuUsage], [[MonitorUtil shareMonitorUtil] memoryUsage]);
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    [[MonitorUtil shareMonitorUtil] startMonitoring];
}


@end
