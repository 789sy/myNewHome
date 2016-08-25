//
//  NSObject+BoardManage.h
//  myNewHome
//
//  Created by user on 16/7/1.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//
//本类别目的： 通过方法注入NSObject的方法，使得应用程序可以在任何地方很方便的查询或跳转页面

#import <Foundation/Foundation.h>

@class AppDelegate;

@interface NSObject (BoardManage)

- (AppDelegate *)appDelegate;

@end
