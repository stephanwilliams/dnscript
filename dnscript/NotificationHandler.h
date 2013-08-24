//
//  NotificationHandler.h
//  dnscript
//
//  Created by Stephan Williams on 8/22/13.
//  Copyright (c) 2013 Stephan Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationHandler : NSObject {
    BOOL _listening;
    BOOL _configLoadSuccess;
    NSDistributedNotificationCenter *_dnCenter;
    NSMutableDictionary *_scriptMap;
}

@property (setter = loadConfigFile:, getter = getConfigFile) NSURL *configFileURL;

- (void)reloadConfigFile;

- (void)startListening;
- (void)stopListening;
- (BOOL)listening;

@end
