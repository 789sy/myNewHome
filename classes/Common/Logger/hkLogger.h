//
//  hkLogger.h
//  myNewHome
//
//  Created by user on 16/5/4.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import <Foundation/Foundation.h>

// DLog is almost a drop-in replacement for NSLog
// DLog();
// DLog(@"here");
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);

#ifdef DEBUG //在build settings --> preprocessing Debug: DEBUG=1  release
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define SN_LOG_MACRO(level, fmt, ...)     [[SNLogger sharedInstance] logLevel:level format:(fmt), ##__VA_ARGS__]
#define SN_LOG_PRETTY(level, fmt, ...)    \
do {SN_LOG_MACRO(level, @"%s #%d " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);} while(0)

#define SNLogError(frmt, ...)   SN_LOG_PRETTY(SNLogLevelERROR, frmt, ##__VA_ARGS__)
#define SNLogWarn(frmt, ...)    SN_LOG_PRETTY(SNLogLevelWARN,  frmt, ##__VA_ARGS__)
#define SNLogInfo(frmt, ...)    SN_LOG_PRETTY(SNLogLevelINFO,  frmt, ##__VA_ARGS__)
#define SNLogDebug(frmt, ...)   SN_LOG_PRETTY(SNLogLevelDEBUG, frmt, ##__VA_ARGS__)

@interface hkLogger : NSObject

@end
