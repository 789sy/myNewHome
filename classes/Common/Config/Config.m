//
//  Config.m
//  myNewHome
//
//  Created by user on 16/6/20.
//  Copyright (c) 2016年 teamwin-hkh. All rights reserved.
//

#import "Config.h"

@implementation Config

-(id) init {
    
    if(!(self = [super init]))
        return self;
    return self;
}

+(Config *) currentConfig {
    
    static Config *instance;
    
    if(!instance)
        
        instance = [[Config alloc] init];
    
    return instance;
}

@end
