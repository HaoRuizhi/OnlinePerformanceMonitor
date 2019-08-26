//
//  MonitorUtil.h
//  OnlinePerformanceMonitor
//
//  Created by xiaoshuang on 2019/8/26.
//  Copyright © 2019年 xiaoshuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MonitorUtil : NSObject

+ (instancetype)shareMonitorUtil;
// 检测CPU使用情况
- (integer_t)cpuUsage;
// 检查FPS
- (void)startMonitoring;
// 内存使用情况
- (unsigned long)memoryUsage;

@end

NS_ASSUME_NONNULL_END
