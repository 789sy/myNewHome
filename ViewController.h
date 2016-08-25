//
//  ViewController.h
//  myNewHome
//
//  Created by user on 16/5/3.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLogConfig.h"
//#define VIEWCTL_DEBUG   1
#if VIEWCTL_DEBUG
#else
#undef DLog
#define DLog(...)
#endif

@interface ViewController : UIViewController


@end

