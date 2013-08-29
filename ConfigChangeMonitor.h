//
//  ConfigChangeMonitor.h
//  dnscript
//
//  Created by Stephan Williams on 8/28/13.
//  Copyright (c) 2013 Stephan Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/event.h>
#import <fcntl.h>
#import "NotificationHandler.h"

@interface ConfigChangeMonitor : NSObject <NSPortDelegate> {
    NotificationHandler *_handler;
    NSPort *srcPort;
    NSPort *dstPort;
}

- (id)initWithNotificationHandler:(NotificationHandler *)handler;
- (void)handlePortMessage:(NSPortMessage *)message;
- (void)monitorConfigChangesWithPort:(id)data;

@end
