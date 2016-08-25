//
//  AppDelegate.h
//  myNewHome
//
//  Created by user on 16/5/3.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLogConfig.h"
#import <AVFoundation/AVFoundation.h>

#if APPDELEGATE_DEBUG
#else
#undef DLog
#define DLog(...)
#endif

@class talk_class;
@class SysInfo;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GCDAsyncSocketDelegate> {
    NSTimer *_timer_fakeTask;
    //DataBean *_receivedBean; //本地通知接受信息
    NSInteger _seq;
    NSDate *_notiFireDate;
    AVAudioPlayer *audioplayer;
    BOOL _ProcessFlag;
}

@property (strong, nonatomic) UIWindow *window;

@property UIBackgroundTaskIdentifier backgroundtaskidentifer;
@property (strong,nonatomic) NSTimer *backgroundTimer;

@property (nonatomic, strong) YTKKeyValueStore *db;
@property (nonatomic, strong) talk_class *talk;
@property (nonatomic, strong) SysInfo *sysInfo;
//@property (nonatomic, strong) GCDAsyncSocket *tcp;

+ (AppDelegate *)currentAppDelegate;


@end

