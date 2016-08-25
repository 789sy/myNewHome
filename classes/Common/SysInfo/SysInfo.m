//
//  SysInfo.m
//  myNewHome
//
//  Created by user on 16/6/30.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import "SysInfo.h"
#include <sys/sysctl.h>
#import <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AppDelegate.h"
#import "talk_class.h"
#import "sqlite3.h"

#define SUBMIT_TIME     @"20160911000000"

@implementation SysInfo {
    AppDelegate *app;
    NSString *lastip;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self initSysInfo];
    app = [AppDelegate currentAppDelegate];
    return self;
}

#pragma mark -
#pragma mark private methods
- (void)initSysInfo {
    [self getOSystemVersionInfo];
}

- (void)getOSystemVersionInfo  {
    _systemVersion = [[UIDevice currentDevice] systemVersion];              //获取当前os的版本
    _UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];    //UUID
}

- (NSDate *)convertDate {
    NSString *string = [[NSString alloc] initWithFormat:@"%@", SUBMIT_TIME];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc]init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate* inputDate = [inputFormatter dateFromString:string];
    
    return inputDate;
}

- (BOOL)isSubmitAPPTime {
    NSDate *curdate = [[NSDate alloc] initWithTimeIntervalSinceNow:3600 * 24];
    DLog(@"当前时间：%@", curdate);
    DLog(@"设定时间：%@", [self convertDate]);
    return _isSubmitAPPTime;
}

#pragma mark -
#pragma mark public methods
- (NSString *)macAddress {
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    buf = malloc(len);
    if (buf == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        //printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    if([outstring isEqualToString:@"02:00:00:00:00:00"]) {
        outstring = _equmac;
    }
    //NSString *outstring = [NSString stringWithFormat:@"E4:25:E7:56:B8:EE"];
    //NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    //NSLog(@"%@",outstring);
    free(buf);
    return [outstring uppercaseString];
}

//获取ip地址，同时更新到服务器
- (NSString *)getLocalIP {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    if (![address isEqualToString:lastip]) {
        DLog(@"ipchanged");
        [app.talk sendTcpInMain];       //发送本机新的ip到服务器
    }
    lastip = [address copy];
    return address;
}

//
- (void)readAPPSystemInfo {
    //app.db
    DLog(@"read AppSystem info ...");
    DLog(@"equid:%@", [app.db getStringById:@"equmac" fromTable:@"linet_sysinfo"]);
    
    //sqlite3 *db = app.db.;
        NSString *sql = @"SELECT * FROM linet_sysinfo";
        sqlite3_stmt * statement;
        if (sqlite3_prepare_v2((__bridge sqlite3 *)(app.db), [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            char *temp;
            if(sqlite3_step(statement) == SQLITE_ROW) {
                temp = (char *)sqlite3_column_text(statement, 0);
                self.equid = [NSString stringWithUTF8String:temp];//[[NSString alloc]initWithUTF8String:temp];
                DLog(@"self.equid %@", self.equid);
            }
        }
}

- (NSString *)getServerIp {
    if(_equ_server == 1) {
        return _server_lan;
    }
    return _server_wan;
}

- (NSString *)getRemoteIp:(int)LanOrWan server:(int)server {
    if (LanOrWan == 1) {
        if (server == 1) {
            return _equip;
        }
        else if (server==2) {
            return _server_lan;
        }
        else if (server == 3) {
            return _tserver_lan;
        }
    }
    else {
        if (server == 1) {
            return _server_wan;
        }
        else if (server == 2) {
            return _server_wan;
        }
        else if (server == 3) {
            return _tserver_wan;
        }
    }
    return nil;
}

- (void)addHead:(NSString *)head toByte:(Byte *)bb {
    Byte *tempbb;
    NSString *tempS;
    NSData *tempData;
    tempS = @"XXXCID";
    tempData = [tempS dataUsingEncoding:NSUTF8StringEncoding];
    tempbb = (Byte *)[tempData bytes];
    memcpy(bb, tempbb, 6);
}

- (void)addEquid:(NSString *)equid toByte:(Byte *)bb at:(int)pos {
    Byte *tempbb;
    NSString *tempS;
    NSData *tempData;
    //本地
    tempS = equid;
    tempData = [tempS dataUsingEncoding:NSUTF8StringEncoding];
    tempbb = (Byte *)[tempData bytes];
    memcpy(bb+pos, tempbb, [tempData length]);
    for (int i=(int)[tempData length]; i<20; i++){
        bb[i+pos] = 0;
    }
}

- (void)addMac:(NSString *)mac toByte:(Byte *)bb at:(int)pos {
    NSArray *tempA = [mac componentsSeparatedByString:@":"];
    for (int i=0; i<tempA.count; i++) {
        bb[i+pos] = [self Ox:(NSString *)[tempA objectAtIndex:i]];
    }
}

- (int)Ox:(NSString *)v {
    int n = 0;
    int p = 0;
    NSString *s;
    for (int i=0; i<v.length; i++) {
        s = [v substringWithRange:NSMakeRange(i, 1)];
        if ([s isEqualToString:@"A"]|[s isEqualToString:@"a"]) p=10;
        else if ([s isEqualToString:@"B"]|[s isEqualToString:@"b"]) p=11;
        else if ([s isEqualToString:@"C"]|[s isEqualToString:@"c"]) p=12;
        else if ([s isEqualToString:@"D"]|[s isEqualToString:@"d"]) p=13;
        else if ([s isEqualToString:@"E"]|[s isEqualToString:@"e"]) p=14;
        else if ([s isEqualToString:@"F"]|[s isEqualToString:@"f"]) p=15;
        else p = [s intValue];
        for (int j=i+1; j<v.length; j++) {
            p = p*16;
        }
        n += p;
    }
    return n;
}

- (void)addInt:(int)port toByte:(Byte *)bb at:(int)pos {
    bb[pos+3] = (Byte)((port & 0xFF000000) >> 24);
    bb[pos+2] = (Byte)((port & 0x00FF0000) >> 16);
    bb[pos+1] = (Byte)((port & 0x0000FF00) >> 8);
    bb[pos] = (Byte)((port & 0x000000FF) );
    
}

- (void)addIp:(NSString *)ip toByte:(Byte *)bb at:(int)pos {
    NSArray *tempA = [ip componentsSeparatedByString:@"."];
    for (int i=0; i<tempA.count; i++){
        bb[i+pos] = [(NSString *)[tempA objectAtIndex:i] intValue];
    }
}

- (int)addGKB:(NSString *)equid toByte:(Byte *)bb at:(int)pos {
    Byte *tempbb;
    NSString *tempS;
    NSData *tempData;
    //本地
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    tempS = equid;
    tempData = [tempS dataUsingEncoding:gbkEncoding];
    tempbb = (Byte *)[tempData bytes];
    memcpy(bb+pos, tempbb, [tempData length]);
    return (int)[tempData length]  ;
}

- (void)addShort:(int)port toByte:(Byte *)bb at:(int)pos {
    bb[pos+1] = (Byte)((port & 0x0000FF00) >> 8);
    bb[pos] = (Byte)((port & 0x000000FF) );
    
}

- (BOOL)isLogin {
    return [_equid isEqualToString:@"9999-01-01-01"];
}


@end
