//
//  ModelMsg.h
//  myNewHome
//
//  Created by user on 16/5/4.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelMsg : NSObject

@property (nonatomic, assign)int sid;
@property (nonatomic, strong)NSString *stime;
@property (nonatomic, assign)int type;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *content;
@property (nonatomic, strong)NSString *from;

@property (nonatomic, strong)NSString *img;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *txt;

@end
