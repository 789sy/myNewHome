//
//  myNewHomeConfig.h
//  myNewHome
//
//  Created by user on 16/5/3.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#ifndef myNewHome_myNewHomeConfig_h
#define myNewHome_myNewHomeConfig_h

#ifdef DISTRIBUTION_APPSTORE    //----------------发布到AppStore,勿动

#define kReleaseH            1
#define kMobileReleaseH      1
#define kReleaseInfoH        1
#define kAllowInvalidHttps   0

#elif DISTRIBUTION_JAILBROKEN   //----------------越狱渠道发布，勿动

#define kReleaseH            1
#define kMobileReleaseH      1
#define kReleaseInfoH        1
#define kAllowInvalidHttps   0

#else //----------------自己配置

//1、基本网络环境切换
//#define kPreTest        1
//#define kSitTest        1
#define kReleaseH        1

#endif

//数据库调试打印 开关
#define DB_DEBUG    //开
//#undef DE_DEBUG   //关

#endif
