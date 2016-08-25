//
//  UdpData.h
//  myNewHome
//
//  Created by user on 16/7/19.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdpData : NSObject

@property (nonatomic, assign) BOOL isUsed;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, strong) NSString *toHost;
@property (nonatomic, assign) int tag;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) int byport;
@property (nonatomic, assign) int sendtimes;
@property (nonatomic, assign) int sendtimesneed;
@property (nonatomic, assign) int res;

@end
