//
//  mainViewController.h
//  myNewHome
//
//  Created by user on 16/6/20.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLogConfig.h"

#if MAIN_VIEW_CTR_DEBUG
#else
#undef DLog
#define DLog(...)
#endif

@interface mainViewController : UIViewController

@end
