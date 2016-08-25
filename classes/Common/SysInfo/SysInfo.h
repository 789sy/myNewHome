//
//  SysInfo.h
//  myNewHome
//
//  Created by user on 16/6/30.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SysInfo : NSObject {
    
}

@property (nonatomic, copy) NSString *equid;
@property (nonatomic, copy) NSString *equip;
@property (nonatomic, copy) NSString *equmac;
@property (nonatomic, assign) int port;
@property (nonatomic, copy) NSString *server;//url
@property (nonatomic, strong) NSString * server_wan;
@property (nonatomic, copy) NSString *server_lan;
@property (nonatomic, assign) int equ_server;
@property (nonatomic, assign) int code_mode;
@property (nonatomic, assign) int user;
@property (nonatomic, copy) NSString *lasttime;
@property (nonatomic, assign) int maxid;
@property (nonatomic, assign) int _areaid;
@property (nonatomic, copy) NSString *areaname;
@property (nonatomic, assign) int reporttime;
@property (nonatomic, copy) NSString *tserver;
@property (nonatomic, copy) NSString *tserver_wan;
@property (nonatomic, copy) NSString *tserver_lan;
@property (nonatomic, copy) NSString *areaid;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, assign) int subequid;
@property (nonatomic,copy) NSString *sysver;

@property (nonatomic, assign) BOOL isSubmitAPPTime;         //app提交时间
@property (nonatomic, copy) NSString *systemVersion;        //获取当前os的版本
@property (nonatomic, copy) NSString *UUID;                 //UUID  已被禁用

@property float vol;
@property float micvol;
@property (nonatomic, retain) NSString *localip;
@property (nonatomic, retain) NSString *localequid;
@property (nonatomic, assign) Byte *localequid_bb;

@property (nonatomic, assign) BOOL isLogin;

- (NSString *)macAddress;                                   //获取mac地址，其实还是要手动填
- (NSString *)getLocalIP;                                   //获取ip地址
- (void)readAPPSystemInfo;                                  //从数据读app配置信息
- (NSString *)getServerIp;                                  //获取服务器ip
- (NSString *)getRemoteIp:(int)LanOrWan server:(int)server; //获取远处ip

- (void)addHead:(NSString *)head toByte:(Byte *)bb;         //
- (void)addEquid:(NSString *)equid toByte:(Byte *)bb at:(int)pos;
- (void)addMac:(NSString *)mac toByte:(Byte *)bb at:(int)pos;
- (void)addInt:(int)port toByte:(Byte *)bb at:(int)pos;
- (void)addIp:(NSString *)ip toByte:(Byte *)bb at:(int)pos;
- (int)addGKB:(NSString *)equid toByte:(Byte *)bb at:(int)pos;
- (void)addShort:(int)port toByte:(Byte *)bb at:(int)pos;


@end
