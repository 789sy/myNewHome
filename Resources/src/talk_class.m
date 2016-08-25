//
//  talk_class.m
//  myNewHome
//
//  Created by user on 16/7/4.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import "talk_class.h"
#import "AppDelegate.h"
#import "SysInfo.h"

#define UDP_PORT    8302        //暂时用固定端口，后面用动态端口
#define BUFNUM      100

@implementation talk_class {
    AppDelegate *app;
    NSTimer *timer_1s;      //1秒钟定时器
    
    BOOL isTcpConnected;
    BOOL isConnect2;
    BOOL isBack;
    int loop;
    int loop2;
    int lostTime2;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self udpOpen];
    [self timerOneSecondInit];
    [NSThread detachNewThreadSelector:@selector(sendTcpThread) toTarget:self withObject:nil];
    app = [AppDelegate currentAppDelegate];
    return self;
}

#pragma mark -
#pragma mark private methods
- (void)udpOpen {
    _udp = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (YES == [self.udp bindToPort:UDP_PORT error:&error]) {
        DLog(@"udp2 绑定端口%d 成功 ...", UDP_PORT);
    }
    else {
        DLog(@"udp2 绑定端口%d 失败 ...", UDP_PORT);
    }
    if (YES == [self.udp enableBroadcast:YES error:&error]) {
        DLog(@"udp2 发送广播设置 成功 ...");
    }
    else {
        DLog(@"udp2 发送广播设置 失败 ...");
    }
    if (YES == [self.udp joinMulticastGroup:@"238.9.9.1" error:&error]) {
        DLog(@"udp2 加入组群%@ 成功 ...", @"238.9.9.1");
    }
    else {
        DLog(@"udp2 加入组群%@ 失败 ...", @"238.9.9.1");
    }
}

//1秒钟定时器
- (void)timerOneSecondInit {
    timer_1s = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(timer_1Second)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)timer_1Second {
    if (YES == [self.udp isClosed]) { //socket关闭后，重新连接
        [self udpOpen];
    }
    
    if([self.tcp isConnected]) {
        //NSLog(@"tcp ok    ip:%@",[self getLocalIP]);
    }
    else {
        DLog(@"tcp err   ip:%@",[app.sysInfo getLocalIP]);
        @try {
            NSError *err = nil;
            NSLog(@"setTime %d", __LINE__);
            if (![_tcp connectToHost:app.sysInfo.server_wan onPort:8302 error:&err]) {
                isTcpConnected = false;
                DLog(@"Error: %@", err);
            } else {
                DLog(@"timer_1Second");
            }
        } @catch (NSException *e) {
            
        }
    }
    
    if (isBack) {
        if (_status == 6) {
            if (!isTcpConnected) {
                DLog(@"tcpsend:lost");
                @try
                {
                    NSError *err = nil;
                    DLog(@"setTime %d", __LINE__);
                    if(![_tcp connectToHost:app.sysInfo.server_wan onPort:8302 error:&err])
                    {
                        isTcpConnected = false;
                        DLog(@"Error: %@", err);
                    }
                    else{
                        isTcpConnected = YES;
                    }
                } @catch (NSException *e) {
                    
                }
                
            }
            else {
                //DLog(@"setTime %d", __LINE__);
                NSString *str = [[NSString alloc]initWithFormat:@"wakeupme"];
                NSData* aData = [str dataUsingEncoding: NSUTF8StringEncoding];
                [_tcp writeData:aData withTimeout:-1 tag:1];
            }
        }
        return;
    }
    
    @try {
        if(app.sysInfo._areaid == -1) {

        } else {
            if (loop2 >= app.sysInfo.reporttime) {//心跳包时间 如果没有收到udp回应 则继续发
                
                loop2 = 0;
                Byte bb[110];
                memset(bb, 0, 82);
                [app.sysInfo addHead:@"XXXCID" toByte:bb];
                bb[6] = 4;
                bb[7] = 1;
                [app.sysInfo addEquid:app.sysInfo.localequid toByte:bb at:8]; //localequid 存在数据库
                bb[20] = 0;
                [app.sysInfo addMac:[app.sysInfo macAddress] toByte:bb at:28];
                [app.sysInfo addInt:app.sysInfo._areaid toByte:bb at:34];
                app.sysInfo.localip = [app.sysInfo getLocalIP];
                [app.sysInfo addIp:app.sysInfo.localip toByte:bb at:38];
                if (app.sysInfo.isLogin) {
                    if((![app.sysInfo.username isEqualToString:@""])&(![app.sysInfo.username isEqualToString:@"admin"])) {
                        //未获取房号  已登录
                        bb[7] = 3;
                        [app.sysInfo addGKB:app.sysInfo.username toByte:bb at:42];
                        NSData *data = [[NSData alloc] initWithBytes:bb length:82];
                        [_udp sendData:data
                                     toHost:[app.sysInfo getServerIp]
                                       port:8302
                                withTimeout:-1
                                        tag:0];
                    }
                    else {
                        //房号为9999010101且未登陆 不发送心跳包
                    }
                }
                else { //未登录
                    [app.sysInfo addGKB:app.sysInfo.sysver toByte:bb at:50];
                    int len = [app.sysInfo addGKB:app.sysInfo.username toByte:bb at:60];
                    [app.sysInfo addShort:len toByte:bb at:43];
                    NSData *data = [[NSData alloc] initWithBytes:bb length:60+len];
                    [_udp sendData:data
                                 toHost:[app.sysInfo getServerIp]
                                   port:8302
                            withTimeout:-1
                                    tag:0];
                }
            }
            else {
                loop2++;
            }
            
            lostTime2++;
            if (lostTime2 > 3*app.sysInfo.reporttime) {
                isConnect2 = false;
                lostTime2 = 0;
            }
        }
    } @catch (NSException * ex) {
        DLog(@"心跳包错误");
    }
    
}

//创建udp发送线程
- (void)createUdpSendThread {
    _udp_datas = [[NSMutableArray alloc] init];
    UdpData *list;
    _udp_list = [[UdpData alloc] init];
    
    for (int i=0; i<BUFNUM; i++) {
        list = [[UdpData alloc] init];
        list.isUsed = FALSE;
        [_udp_datas addObject:list];
    }
    _udp_send_tag = YES;
    _udp_send_time = 0;
    
    [NSThread detachNewThreadSelector:@selector(udpSendThread) toTarget:self withObject:nil];
}

//upd发送线程
- (void)udpSendThread {
    while(_udp_send_tag) {
        while (_udp_send_time <= 0) {
            @try {
                [_udp_send_Condition wait];
                sleep(1);
            }
            @catch (NSException * e) {
            }

        }
        [_udp_send_Condition lock];
        //事件
        BOOL hasDataSend = YES;
        while (hasDataSend) {
            @try
            {
                hasDataSend = FALSE;
                for(int i=0; i<BUFNUM; i++) {
                    _udp_list = [_udp_datas objectAtIndex:i];
                    if (_udp_list.isUsed) { //向服务器发送数据
                        DLog(@"hasDataSend:i=%d", i);
                        if(_udp_list.sendtimes < _udp_list.sendtimesneed) { //发送时间超时判断 未超时
                            hasDataSend = YES;
                            _udp_list.sendtimes ++;
                            [_udp_datas replaceObjectAtIndex:i withObject:_udp_list];
                            if ((_udp_list.port == 8300)||(_udp_list.byport == 8300)) {
                                //[self performSelectorOnMainThread:@selector(sendDataInMain) withObject:nil waitUntilDone:YES];
                            }
                            else {
                                //NSArray *aa=[[NSArray alloc] initWithObjects:udp_list.data,udp_list.toHost,[[NSString alloc] initWithFormat:@"%d",8302], nil];
                                [self performSelectorOnMainThread:@selector(sendUdpData) withObject:nil waitUntilDone:YES];
                            }
                        }
                        else {                                      //发送数据到服务器，超时 处理 无法连接
                            _udp_list.sendtimes = 0;
                            _udp_list.isUsed = FALSE;
                            [_udp_datas replaceObjectAtIndex:i withObject:_udp_list];
                            
                            Byte *bb = (Byte *)[_udp_list.data bytes];
                            switch (bb[6]) {
                                case 119: {
                                    if ((bb[8] == 30)||(bb[8] == 33)) {
                                        DLog(@"更新失败");
                                        if (bb[8] == 33) {
                                            //[self performSelectorOnMainThread:@selector(setPageToMain) withObject:nil waitUntilDone:YES];
                                        }
                                        
                                    }
                                    if (bb[8] == 42) {
                                        //[self alertInMain:@"操作失败，无法连接服务器"];
                                    }
                                    if (bb[8] == 26) {
                                        //[self alertInMain:@"报修失败，无法连接服务器"];
                                    }
                                    if (bb[8] == 110) {
                                        //[self alertInMain:@"开门失败，无法连接服务器"];
                                        //[self performSelectorOnMainThread:@selector(setPageToLock) withObject:nil waitUntilDone:YES];
                                    }
                                }
                                    break;
                                case 150: {//通话
                                    /*
                                    if(bb[8]==1) {
                                        if ([_udp_list.toHost isEqualToString:self.sysinfo.server_lan]){
                                            NSLog(@"呼叫失败");
                                            [talk_class status_ini_onMain];
                                            [self alertInMain:@"呼叫失败"];
                                        }
                                        else if ([udp_list.toHost isEqualToString:self.sysinfo.server_wan]){
                                            NSLog(@"呼叫失败");
                                            [talk_class status_ini_onMain];
                                            [self alertInMain:@"呼叫失败"];
                                        }
                                        else {
                                            NSLog(@"服务器转移");
                                            int bblen=62;//512
                                            Byte bb2[bblen];
                                            memcpy(bb2,bb,57);
                                            bb2[57]=0;
                                            [self addInt:self.sysinfo._areaid toByte:bb2 at:58];
                                            NSData *data2 = [[NSData alloc] initWithBytes:bb length:bblen];
                                            
                                            [self senddataInThr:data2 toHost:[self getServerIp] toPort:8302 byPort:8302 at:6 setTag:0];
                                            
                                        }
                                     
                                    }
                                    else if(bb[8]==10) {
                                        NSLog(@"开锁失败");
                                    }
                                    else if(bb[8]==30) {
                                        NSLog(@"停止通话失败");
                                        //[talk_class status_ini_onMain];
                                    }
                                     */
                                }
                                    break;
                                case 154: {//解析地址失败
                                    if([_udp_list.toHost isEqualToString:@"238.9.9.1"]){
                                        DLog(@"toserver");
                                        //[talk_class NSToServer];
                                    }
                                    else {
                                        //[talk_class status_ini_onMain];
                                        //[self alertInMain:@"找不到设备"];
                                    }
                                    
                                }
                                    break;
                                case 155: {//解析地址失败
                                    //[talk_class status_ini_onMain];
                                    //[self alertInMain:@"找不到设备"];
                                }
                                    break;
                                case 214: {
                                    if(bb[8] == 2) {
                                        //[self alertInMain:@"投票失败，无法连接服务器"];
                                    }
                                }
                                    break;
                                default:
                                    break;
                                    
                            } 
                            
                        }
                    }
                    else {
                        
                    }
                }
                
                sleep(1);
            } @catch (NSException *e) {
                
            }
            
        }
    }
}

- (void)sendUdpData {
    Byte *bb = (Byte *)[_udp_list.data bytes];
    DLog(@"udp_list.data rr[6] = %d, rr[7] = %d, [8] = %d", bb[6], bb[7], bb[8]);
    DLog(@"8302发送数据 %@:%d", _udp_list.toHost, _udp_list.port);
    
    //BOOL res = YES;
    if (_udp_list.tag == 0) {
        [_udp sendData:_udp_list.data
                toHost:_udp_list.toHost
                  port:_udp_list.port
           withTimeout:-1
                   tag:0
         ];
        DLog(@"8302发送数据end %@:%d",_udp_list.toHost, _udp_list.port);
    }
    else if (_udp_list.tag == 1) {//呼叫数据第一包
        _udp_list.tag = 2;
        [_udp sendData:_udp_list.data
                toHost:_udp_list.toHost
                  port:8301
           withTimeout:-1
                   tag:0
         ];
        DLog(@"8302发送数据end %@:%d", _udp_list.toHost, 8301);
    }
    else if (_udp_list.tag == 2) {//呼叫数据后面几包
        [_udp sendData:_udp_list.data
                toHost:_udp_list.toHost
                  port:_udp_list.port
           withTimeout:-1
                   tag:0
         ];
        
        [_udp sendData:_udp_list.data
                toHost:_udp_list.toHost
                  port:8302
           withTimeout:-1
                   tag:0
         ];
        DLog(@"8302发送数据end %@:%dand%d", _udp_list.toHost, _udp_list.port, 8302);
    }
    else {
        [_udp sendData:_udp_list.data
                toHost:_udp_list.toHost
                  port:_udp_list.port
           withTimeout:-1
                   tag:0
         ];
        DLog(@"8302发送数据end %@:%d", _udp_list.toHost, _udp_list.port);
    }
    //return res;
}

//tcp 线程 10秒钟
- (void)sendTcpThread {
    while (true) {
        [self performSelectorOnMainThread:@selector(sendTcpInMain) withObject:nil waitUntilDone:YES];
        sleep(10);
    }
}

- (void)sendTcpInMain {
    DLog(@"sendTcpInMain ...");
}

#pragma mark -
#pragma mark custom methods


#pragma mark -
#pragma mark UDP Delegate Methods  upd接受到的消息处理
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    DLog(@"UPD didReceiveData ...");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSString *addr = [[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding];
    DLog(@"udp didConnectToAddress %@", addr);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    DLog(@"%@",error);
    DLog(@"not send");
    //return YES;
}

//- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    //NSLog(@"udp send ...");
    //return YES;
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    //Called when the socket is closed.
    DLog(@"socket is closed ...");
}

#pragma mark -
#pragma mark TCP Delegate Methods

@end
