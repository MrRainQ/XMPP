//
//  Common.h
//  即时通讯
//
//  Created by sen5labs on 14-9-19.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "NSString+Helper.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif