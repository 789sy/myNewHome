//
//  HKDB.m
//  Sqlite3
//
//  Created by hkh on 16/5/04.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import "HKDB.h"
#import <sqlite3.h>
#import "DLogConfig.h"

//#define HKDB_DEBUG   1
#if HKDB_DEBUG
#else
#undef DLog
#define DLog(...)
#endif

static sqlite3 * db;// 定义数据库指针对象，只有一个

@implementation HKDB {
    
}

//打开
+ (sqlite3 *)openDataBase
{
#if 0
    // 如果数据库存在，则不再创建新的对象
    if (dbpoint) {
        return dbpoint;
    }
    //  先将数据库文件从bundle包拷贝到documents包中
    //  只拷贝一次，避免覆盖
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);// 获得文件夹路径
    NSString * path = [paths lastObject];// 获得路径
    path = [NSString stringWithFormat:@"%@/%@",path,@"person.db"];//  创建document文以及路径,表名
    
    DLog(@"文件路径为:%@", path);
    // 文件管理类NSFileManager
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])//根据文件的路径来判断文件是否存在
    {   // 拷贝,将bundle文件夹的文件内容拷贝到document
        
        NSString * sourcepath = [[NSBundle mainBundle]pathForResource:@"Person" ofType:@"rdb"];// 找到路径(数据库)
        
        [[NSFileManager defaultManager] copyItemAtPath:sourcepath  toPath:path error:NULL];// 拷贝数据库，到path（document）
    }
    // 根据路径打开数据库，并获得数据库只针对象
    
    sqlite3_open([path UTF8String], &dbpoint);
    return dbpoint;
#endif
    
    //打开数据库
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //获取应用程序生成一个私有目录/Users/apple/Library/Application Support/iPhone Simulator/4.3/Applications/550AF26D-174B-42E6-881B-B7499FAA32B7/Documents
    NSString *documentsDirectory = [paths objectAtIndex:0];   //
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"linetsql.sqlite"];
    
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        DLog(@"数据库打开失败");
    }
    else {
        DLog(@"数据库打开成功");
    }
    
    return db;
}

//数据库操作
- (void)sqlexe:(NSString *)sql {
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        DLog(@"数据库操作数据失败!");
    }
}
//检查表是否存在
- (BOOL)isTabelExist:(NSString *)tableName {
    if (tableName == nil) {
        return FALSE;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master where type='table' and name='%@';",tableName];
    char *err;
    if(sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) == 1) {
        DLog(@"表%@存在 ...", tableName);
        return TRUE;
    } else {
        DLog(@"表%@不存在 ...", tableName);
        return FALSE;
    }
}
/*
//linet_sysinfo表是否存在
- (BOOL)isSysInfoExist {
    NSString *sql =  @"SELECT * FROM linet_sysinfo";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        DLog(@"sysinfo存在 ...");
        //[app readSystemInfo];
        //DLog(@"read end ...");
        return TRUE;
    } else {
        return FALSE;
    }
}
 */
//创建linet_sysinfo表,初始化表
- (void)createSysInfoTableAndInit {
    DLog(@"创建sysinfo表并初始化 ...");
    //创建系统参数表
    NSString *sql = @"DROP TABLE if exists linet_sysinfo";
    DLog(@"db drop ...");
    [self sqlexe:sql];
    DLog(@"drop_end");
    
    sql = @"create table linet_sysinfo(equid string, equip string, equmac string, port integer, server string, server_wan string, server_lan string, equ_server integer, code_mode integer, user integer, lasttime datetime, maxid int, _areaid int, areaname string, username string, subequid integer)";
    [self sqlexe:sql];
    //清空系统参数表
    sql = @"delete from linet_sysinfo";
    [self sqlexe:sql];
    //初始化系统参数表
    sql = @"insert into linet_sysinfo values('9999-01-01-01','192.168.1.10','02:00:00:00:00:00',8300,'116.204.66.159','116.204.66.159','192.168.1.71',2,1,0,'1999-11-11 11:11:11',1,-1,'无','',1)";
    [self sqlexe:sql];
}
//创建报警网关linet_alarm_gate 表,初始化表
- (void)createAlarmGateAndInit {
    DLog(@"创建linet_alarm_gate表并初始化 ...");
    NSString *sql = @"create table linet_alarm_gate(id integer PRIMARY KEY AUTOINCREMENT ,gate_name string)";
    [self sqlexe:sql];
    sql = @"delete from linet_alarm_gate";
    [self sqlexe:sql];
    sql = @"insert into linet_alarm_gate values(null,'测试G888888')";
    [self sqlexe:sql];
}
//创建报警网关设备linet_alarm_gate_equ 表,初始化表
- (void)createAlarmGateEquAndInit {
    DLog(@"创建linet_alarm_gate_equ表并初始化 ...");
    NSString *sql = @"create table linet_alarm_gate_equ(id integer PRIMARY KEY AUTOINCREMENT ,gate_name string, equ_name string, equ_type integer, equ_id integer, isStudy integer)";
    [self sqlexe:sql];
    sql = @"delete from linet_alarm_gate_equ";
    [self sqlexe:sql];
    sql = @"insert into linet_alarm_gate_equ values(null, '测试G888888', '门磁', 65, 11, 0)";//设备类型 0x41 设备id 0x0b
    [self sqlexe:sql];
    sql = @"insert into linet_alarm_gate_equ values(null, '测试G888888', '红外', 66, 12, 0)";//设备类型 0x42 设备id 0x0c
    [self sqlexe:sql];
    sql = @"insert into linet_alarm_gate_equ values(null, '测试G888888', '烟感', 67, 13, 0)";//设备类型 0x43 设备id 0x0d
    [self sqlexe:sql];
    sql = @"insert into linet_alarm_gate_equ values(null, '测试G888888', '燃气', 68, 14, 0)";//设备类型 0x44 设备id 0x0e
    [self sqlexe:sql];
    sql = @"insert into linet_alarm_gate_equ values(null, '测试G888888', '紧急', 69, 15, 0)";//设备类型 0x45 设备id 0x0f
    [self sqlexe:sql];
}
//
- (void)ifFirstTimeIniSql {
    NSString *sql;
    //sqlite3 *db = app.db;
    sql = @"SELECT * FROM linet_sysinfo";
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        DLog(@"sysinfo存在，获取系统参数");
        //[app readSystemInfo];
        DLog(@"read end ...");
    }
    
}
//初始化
- (void)inisql {
    NSString *sql;
    //linet_myroom
    sql = [[NSString alloc]initWithFormat:@"CREATE TABLE linet_myroom (ID integer PRIMARY KEY AUTOINCREMENT, roomid integer, roomname string)"];
    [self sqlexe:sql];
    sql = @"delete from linet_myroom";
    [self sqlexe:sql];
    for (int i=0;i<5;i++){
        sql = [[NSString alloc] initWithFormat: @"insert into linet_myroom(roomid,roomname) values(%d,'%@%d')",i+1,@"房间",i+1];
        [self sqlexe:sql];
    }
    //ipcamera
    sql = @"CREATE TABLE linet_camera (tim datetime,camera_name string,ddns int,camera_addr string,username string,password string,room int)";
    [self sqlexe:sql];
    sql = @"insert into linet_camera values('2013-11-11 11:11:11','展厅－本地',0,'192.168.1.234:10000:80','admin','123456',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_camera values('2013-11-11 11:11:10','展厅',1,'HJP20130701001:raycommtech.cn','admin','123456',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_camera values('2013-11-11 11:11:09','camera3',1,'PARC000340NLTHS:ddns1200.homca.com','admin','123456',2)";
    [self sqlexe:sql];
    sql = @"insert into linet_camera values('2013-11-11 11:11:08','camera2',1,'DYNE6C0274WP3AX:ddns1200.homca.com','admin','123456',3)";
    [self sqlexe:sql];
    sql = @"insert into linet_camera values('2013-11-11 11:11:07','camera1',1,'DYNE6C02743CYSW:ddns1200.homca.com','admin','123456',4)";
    [self sqlexe:sql];
    //音量
    sql = @"create table linet_volume(volume float ,micvolume float)";
    [self sqlexe:sql];
    sql = @"delete from linet_volume";
    [self sqlexe:sql];
    sql = @"insert into linet_volume values (1, -3)";
    [self sqlexe:sql];
    //初始化场景模式
    sql = @"create table linet_scene(sceneid integer ,scenename string ,note string ,code string)";
    [self sqlexe:sql];
    sql = @"delete from linet_scene";
    [self sqlexe:sql];
    sql = @"insert into linet_scene values(1,'会客模式','暂无描述','2 0 1 0 1')";
    [self sqlexe:sql];
    sql = @"insert into linet_scene values(2,'影院模式','暂无描述','2 0 2 0 1')";
    [self sqlexe:sql];
    sql = @"insert into linet_scene values(3,'基础照明','暂无描述','2 0 3 0 1')";
    [self sqlexe:sql];
    sql = @"insert into linet_scene values(4,'回家模式','暂无描述','2 0 4 0 1')";
    [self sqlexe:sql];
    sql = @"insert into linet_scene values(5,'离家模式','暂无描述','2 0 5 0 1')";
    [self sqlexe:sql];
    sql = @"insert into linet_scene values(6,'全开','暂无描述','2 0 6 0 1')";
    [self sqlexe:sql];
    sql = @"insert into linet_scene values(7,'全关','暂无描述','2 0 7 0 1')";
    [self sqlexe:sql];
    
    sql = @"update linet_sysinfo set lasttime='1999-11-11 11:11:11' ,maxid=1";
    [self sqlexe:sql];
    //初始化短信 报警 报修
    sql = [[NSString alloc]initWithFormat:@"CREATE TABLE linet_doorDevice(id integer,equid string,name string,name_en string)"];
    [self sqlexe:sql];
    //短信
    sql = @"create table linet_Newsms(smsid integer primary key ,smsnum integer)";
    [self sqlexe:sql];
    [self sqlexe:@"delete from linet_Newsms"];
    for(int i=0; i<10; i++){
        [self sqlexe:[[NSString alloc]initWithFormat:@"insert into linet_Newsms values(%d,0)", i]];
    }
    //短信
    sql = @"create table linet_message(id integer, tim datetime, type integer, title string, content string, frm string)";
    [self sqlexe:sql];
    sql = @"delete from linet_message";
    [self sqlexe:sql];
    //报修
    sql = @"create table linet_repair(id integer,type String,stim datetime, etim datetime,op string, detail string)";
    [self sqlexe:sql];
    sql = @"delete from linet_repair";
    [self sqlexe:sql];
    //报警
    sql = @"create table linet_alarm(id integer,type String,stim datetime,etim datetime,tag integer,ot string,op string,os string)";
    [self sqlexe:sql];
    sql = @"delete from linet_alarm";
    [self sqlexe:sql];
    //商品
    sql = @"create table linet_goods(id integer Primary key,shopid integer,class String,name string,img string,price real,unit string,sales integer,monthly_sales integer,tim1 datetime,note string,detail string,pos integer,tag integer)";
    [self sqlexe:sql];
    sql = @"delete from linet_goods";
    [self sqlexe:sql];
    //商店
    sql = @"create table linet_shop(shopid integer primary key,name string,cpos string,website string,op string,phone string,email string,detail string)";
    [self sqlexe:sql];
    sql = @"delete from linet_shop";
    [self sqlexe:sql];
    //订单
    sql = @"create table linet_order(orderid integer primary key,cid integer,cname string,shopid integer,num integer,price real,tprice real,pay_type string,tim1 datetime,tim2 datetime,tim3 datetime,tag string,detail string)";
    [self sqlexe:sql];
    sql = @"delete from linet_order";
    [self sqlexe:sql];
    //购物车
    sql = @"create table linet_shopping_cart(id integer primary key,num integer,tim integer,selected integer)";
    [self sqlexe:sql];
    sql = @"delete from linet_shopping_cart";
    [self sqlexe:sql];
    //访客留影
    sql = @"create table linet_visitor(id integer primary key,imgname string,fromid string,toid string,tim datetime)";
    [self sqlexe:sql];
    sql = @"delete from linet_visitor";
    [self sqlexe:sql];
    //刷卡纪录
    sql = @"create table linet_card(id integer primary key, cardid string, addr string, tim datetime)";
    [self sqlexe:sql];
    sql = @"delete from linet_card";
    [self sqlexe:sql];
    //报修类别
    sql = @"create table linet_repairtype(id integer primary key, type string)";
    [self sqlexe:sql];
    sql = @"delete from linet_repairtype";
    [self sqlexe:sql];
    //政府投票
    sql = @"create table linet_vote(id real primary key,v_id integer,v_class integer,v_type integer,v_floor integer,v_txt string,v_img string,v_stim datetime,v_etim datetime)";
    [self sqlexe:sql];
    sql = @"delete from linet_vote";
    [self sqlexe:sql];
    //账单
    //NSLog(@"账单");
    sql = @"create table linet_bill(timw datetime primary key,string roomid,w real,wpp real,wp real,e real,epp real,ep real,g real,gpp real,gp real,tp real,mouthw string,ifdl string,ifp string,timedl datetime,timp datetime)";
    [self sqlexe:sql];
    sql = @"delete from linet_bill";
    [self sqlexe:sql];
    
    //门口机注册 create by huangkanghui at 2015.09.01 11:40
    sql = @"create table linet_regdoor(type string)";
    [self sqlexe:sql];
    sql = @"delete from linet_regdoor";
    [self sqlexe:sql];
    //服务开通 add by huangkanghui at 2015.10.20 16:50
    // id, 套餐，价格， 时长，
    sql = @"create table ehome_services(id integer primary key, combo string, price integer, duration integer, detail_en string, detail_cn string, tips string)";
    [self sqlexe:sql];
    sql = @"delete from ehome_services";
    [self sqlexe:sql];
    
    sql = @"create table ehome_servicesfuntion(service string)";
    [self sqlexe:sql];
    sql = @"delete from ehome_servicesfuntion";
    [self sqlexe:sql];

    sql = @"create table linet_equinfo (eid integer,etype integer,ename string,room integer)";
    [self sqlexe:sql];
    sql = @"delete from linet_equinfo";
    [self sqlexe:sql];
    sql = @"insert into linet_equinfo values(1,1,'电灯1',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_equinfo values(2,1,'电灯2',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_equinfo values(3,1,'电灯3',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_equinfo values(4,1,'电灯4',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_equinfo values(5,1,'电灯5',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_equinfo values(81,2,'窗帘',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_equinfo values(82,4,'中央空调',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_equinfo values(83,4,'小空调',1)";
    [self sqlexe:sql];
    sql = @"insert into linet_equinfo values(84,4,'小空调',1)";
    [self sqlexe:sql];
}
//获取消息 最后N天的
- (void)readMessageFromSql:(NSMutableArray *)array {
    NSString *sql = [self stringToSqlString:@"linet_message" withIndex:8];
    ModelMsg *msg = [[ModelMsg alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //id integer, tim datetime, type integer, title string, content string, frm string
            msg.sid = sqlite3_column_int(statement, 0);
            
            char *stime = (char *)sqlite3_column_text(statement, 1);
            msg.stime = [[NSString alloc] initWithUTF8String:stime];
            
            msg.type = sqlite3_column_int(statement, 2);
            
            char *title = (char *)sqlite3_column_text(statement, 3);
            msg.title = [[NSString alloc] initWithUTF8String:title];
            
            char *content = (char *)sqlite3_column_text(statement, 4);
            msg.content = [NSString stringWithUTF8String:content];
            
            char *from = (char *)sqlite3_column_text(statement, 5);
            msg.content = [NSString stringWithUTF8String:from];
        }
    }
    NSDate *tempdate = [self nsstringToNSDateWith:msg.stime];
    if (NSOrderedAscending == [[self getSettingDate] compare:tempdate]) {
        [array addObject:msg];
    }
    DLog(@"获取linet_message:%@", array);
}

//linet_visitor
- (void)readVisFromSql:(NSMutableArray *)array {
    ModelMsg *msg = [[ModelMsg alloc] init];
    sqlite3_stmt *statement;
    NSString *sql = [self stringToSqlString:@"linet_visitor" withIndex:5];
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //id integer primary key, imgname string, fromid string, toid string, tim datetime
            char *imageName = (char *)sqlite3_column_text(statement, 1);
            msg.img = [[NSString alloc] initWithUTF8String:imageName];
            
            char *from = (char *)sqlite3_column_text(statement, 2);
            msg.img = [[NSString alloc] initWithUTF8String:from];
        }
    }
}

// 关闭
+ (void)close
{
    sqlite3_close(db);
}

//下面几个方法 暂时先放在这里
- (NSString *)stringToSqlString:(NSString *)tableName withIndex:(int)index {
    NSDate *date1 = [[NSDate alloc] initWithTimeIntervalSinceNow:-4 * 3600 * 24];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT * FROM '%@' WHERE tim > '%@' order by tim desc limit 0,%d",tableName, date1, index];
    NSRange pos = [sql rangeOfString:@" +0000"];
    [sql deleteCharactersInRange:pos];
    return sql;
}

- (NSDate *)getSettingDate {
    return ([[NSDate alloc] initWithTimeIntervalSinceNow:-4 * 3600 * 24]);
}

- (NSDate *)nsstringToNSDateWith:(NSString *)date{
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    NSDate *tempDate = [inputFormatter dateFromString:date];
    
    return tempDate;
}

@end
