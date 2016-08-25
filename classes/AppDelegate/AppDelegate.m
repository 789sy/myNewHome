//
//  AppDelegate.m
//  myNewHome
//
//  Created by user on 16/5/3.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import "AudioToolbox/AudioToolbox.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "mainViewController.h"
#import "talk_class.h"
#import "SysInfo.h"

#define UDP_PORT    8302        //暂时用固定端口，后面用动态端口

@interface AppDelegate ()

@end

@implementation AppDelegate {
    
}

#pragma mark -
#pragma mark application life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //推送
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:
                                                       UIUserNotificationTypeAlert|
                                                       UIUserNotificationTypeBadge|
                                                       UIUserNotificationTypeSound categories:nil]];
    }
    //IOS设备过了设定的休眠时间后，都会自动锁屏，此处设置为 保持屏幕一直开着
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//default is NO
    [self dataBaseInit];                //数据库
    //对讲
    //_talk = [[talk_class alloc] init];
    _sysInfo = [[SysInfo alloc] init];
    //进入主界面
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[mainViewController new]];
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DLog(@"应用程序将要进入非活动状态，即将进入后台");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DLog(@"如果应用程序支持后台运行，则应用程序已经进入后台运行");
    
    _backgroundtaskidentifer = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        
        // 当应用程序留给后台的时间快要到结束时（应用程序留给后台执行的时间是有限的）， 这个Block块将被执行
        // 我们需要在次Block块中执行一些清理工作。
        // 如果清理工作失败了，那么将导致程序挂掉
        
        // 清理工作需要在主线程中用同步的方式来进行
        [self clearFakeTask];
    }];
    
    // 模拟一个Long-Running Task
    _timer_fakeTask =[NSTimer scheduledTimerWithTimeInterval:10.0f
                                                      target:self
                                                    selector:@selector(fakeTaskMethod) userInfo:nil
                                                     repeats:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DLog(@"应用程序将要进入活动状态，即将进入前台运行");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DLog(@"应用程序已进入前台，处于活动状态");
    if (_backgroundtaskidentifer != UIBackgroundTaskInvalid){
        
        [self clearFakeTask];
    }
    [self clearBackgroundtask];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DLog(@"应用程序将要退出，通常用于保存数据和一些退出前的清理工作");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // try to clean up as much memory as possible. next step is to terminate app
    DLog(@"系统内存不足，需要进行清理工作");
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
    // midnight, carrier time update, daylight savings time change
    DLog(@"当系统时间发生改变时执行");
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
    // in screen coordinates
    DLog(@"StatusBar框将要变化");
}

#pragma mark -
#pragma mark private methods
- (void)dataBaseInit {
    // 打开名为test.db的数据库，如果该文件不存在，则创新一个新的。
    
    //打开数据库
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //获取应用程序生成一个私有目录
    NSString *documentsDirectory = [paths objectAtIndex:0];   //
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"linetsql.sqlite"];
    _db = [[YTKKeyValueStore alloc] initWithDBWithPath:path];
    if (_db) {
        DLog(@"数据库打开成功");
    }
    else {
        DLog(@"数据库打开失败");
    }
    
}

- (void)processLocalNotification {
    //DLog(@"processLocalNotification ...");
}


#pragma mark -
#pragma mark public methods
+ (AppDelegate *)currentAppDelegate {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}



#pragma mark backgroundtask
- (void)fakeTaskMethod {
    NSLog(@"I'm a fake task! time_remaining=%.2fs",[[UIApplication sharedApplication] backgroundTimeRemaining]);
    if (_backgroundTimer==nil) { //加一层保护 防止有后台任务而后台没有启动
        [self startBackgroundtask];
    }
}

- (void)startBackgroundtask {
    //if ([UIApplication sharedApplication].scheduledLocalNotifications.count>0) {
    if ([UIApplication sharedApplication].scheduledLocalNotifications.count==0) {
        [self playSilenceSound];
        if (_backgroundTimer==nil) {
            _backgroundTimer =[NSTimer scheduledTimerWithTimeInterval:1.0f
                                                               target:self
                                                             selector:@selector(backgroundTimerMethod) userInfo:nil
                                                              repeats:YES];
        }
        
        DLog(@"后台任务开启");
    }else{
        //[self stopSilenceSound];
        DLog(@"无任务，不开启后台");
    }
}

- (void)backgroundTimerMethod {
    DLog(@"I'm still alive!");
    
    [self performSelector:@selector(processLocalNotification) withObject:nil afterDelay:1.2f];
#if 1
    for (UILocalNotification *ln in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        //        NSLog(@"%@ %@",[NSDate date],ln.fireDate);
        NSTimeInterval timeLeft = [ln.fireDate timeIntervalSinceDate:[NSDate date]];
        if (timeLeft<=1&&timeLeft>0) {
            _ProcessFlag = YES;
            NSDictionary *dic = [ln userInfo];
            NSString *beanIdentifer = [dic objectForKey:@"Identifer"];
            if (beanIdentifer.length==0) {
                beanIdentifer = [dic objectForKey:@"NapIdentifer"];
            }
            //_receivedBean = [myCoreData queryDataBean:beanIdentifer];
            _seq = [[ln.userInfo objectForKey:@"Sequence"] intValue];
            _notiFireDate = ln.fireDate;
            
            [self performSelector:@selector(processLocalNotification) withObject:nil afterDelay:1.2f];
        }
    }
#endif
}

- (void)clearFakeTask {
    DLog(@"clearFakeTask ...");
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^(void) {
        [_timer_fakeTask invalidate];// 停止定时器
        // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉应用程序你已经执行完成了。
        // 也就是说,我们向 iOS 要更多时间来完成一个任务,那么我们必须告诉 iOS 你什么时候能完成那个任务。
        // 也就是要告诉应用程序：“好借好还”嘛。
        // 标记指定的后台任务完成
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundtaskidentifer];
        // 销毁后台任务标识符
        _backgroundtaskidentifer = UIBackgroundTaskInvalid;
    });
}

- (void)clearBackgroundtask {
    [self stopSilenceSound];
    [_backgroundTimer invalidate];
    _backgroundTimer = nil;
    DLog(@"后台任务结束");
}

#pragma mark - Audio
- (void)playSilenceSound {
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    //[[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionDuckOthers
                   error:nil];
    //AudioSessionInitialize 方法过时 暂时先这样用 下面是新方法
    //AudioSessionInitialize(NULL, NULL, interruptionListenner, (__bridge void*)self);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listennerNotificationSelector:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"Piano" ofType:@"caf"];
        //该方法 返回 主束文件夹下 “莫斯科没有眼泪.mp3” 文件的路径字符串，如果没有该文件的话，返回null。
        //DLog(@"music file path:%@",path);
        
        if(path!=nil){
            NSURL * url = [NSURL fileURLWithPath:path];
            audioplayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];//实例化 一个player 并指定其播放的歌曲。
            audioplayer.numberOfLoops = -1;//设置循环播放的次数： -1 代表 一直循环播放！
            [audioplayer prepareToPlay];
            [audioplayer setVolume:0];
            [audioplayer play];
        };//如果 没有音乐问文件，则直接退出，否者执行下面代码 回出问题。
    }
}

- (void)stopSilenceSound {
    if (audioplayer.playing) {
        [audioplayer stop];
        audioplayer = nil;
    }
}

void interruptionListenner(void* inClientData, UInt32 inInterruptionState) {
    AppDelegate* pTHIS = (__bridge AppDelegate*)inClientData;
    if (pTHIS) {
        if (kAudioSessionBeginInterruption == inInterruptionState) {
            printf("\nBegin interruption\n");
            [pTHIS clearBackgroundtask];
        }
        else {
            printf("\nBegin end interruption\n");
            [pTHIS startBackgroundtask];
            printf("\nEnd end interruption\n");
        }
        
    }
}

- (void)listennerNotificationSelector:(NSNotification *)notificationSender {
    DLog(@"AVAudioSessionInterruptionNotification ...")
    NSDictionary *userInfoDic = (NSDictionary *)notificationSender;
    NSUInteger AVAudioSessionInterruptionType = (NSUInteger)userInfoDic[AVAudioSessionInterruptionTypeKey];
    if (AVAudioSessionInterruptionTypeBegan == AVAudioSessionInterruptionType) {
        [self clearBackgroundtask];
    }
    else {
        [self startBackgroundtask];
    }
}

@end
