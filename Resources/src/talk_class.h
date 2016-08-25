//
//  talk_class.h
//  myNewHome
//
//  Created by user on 16/7/4.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLogConfig.h"
#import "UdpData.h"

#if TALK_CLASS
#else
#undef DLog
#define DLog(...)
#endif


@interface talk_class : NSObject <GCDAsyncUdpSocketDelegate> {
}

@property int status;//0：初始状态 1：等待监视 2：  3：监视中 4：呼叫成功 5：主角通话中  6：被叫通话  8：被叫通话中

@property (nonatomic, strong) GCDAsyncUdpSocket *udp;
@property BOOL udp_send_tag;
@property (nonatomic, retain) NSCondition *udp_send_Condition;
@property (nonatomic, retain) NSCondition *udp_open_Condition;
@property int udp_send_time;
@property (nonatomic, retain) NSMutableArray *udp_datas;
@property (nonatomic, retain) UdpData *udp_list;

@property (nonatomic, retain) GCDAsyncSocket *tcp;

- (void)sendTcpInMain;

@end
