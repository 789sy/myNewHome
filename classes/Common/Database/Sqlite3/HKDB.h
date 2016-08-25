//
//  HKDB.h
//  Sqlite3
//
//  Created by hkh on 16/5/04.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ModelMsg.h"

@interface HKDB : NSObject
{
    BOOL _isInitializeSuccess;
    
    BOOL _isDataBaseOpened;
}
/*!
 *  创建数据库，数据库文件从bundle包拷贝到documents包中
 *
 *  @return 数据库指针
 */
+ (sqlite3 *)openDataBase;

//数据库操作
- (void)sqlexe:(NSString *)sql;
//检查表是否存在
- (BOOL)isTabelExist:(NSString *)tableName;
//创建linet_sysinfo表,初始化表
- (void)createSysInfoTableAndInit;
//创建报警网关linet_alarm_gate 表,初始化表
- (void)createAlarmGateAndInit;
//创建报警网关设备linet_alarm_gate_equ 表,初始化表
- (void)createAlarmGateEquAndInit;
//
- (void)inisql;

/*!
 *  关闭数据库
 */
+ (void)close;

@end
