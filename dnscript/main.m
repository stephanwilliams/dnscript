//
//  main.m
//  dnscript
//
//  Created by Stephan Williams on 8/21/13.
//  Copyright (c) 2013 Stephan Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/event.h>
#import <fcntl.h>
#import "NotificationHandler.h"

#define kDNSCRIPT_CONFIG_FILE_NAME @".dnscriptrc"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSLog(@"Starting dnscript agent");
        
        NSURL *userHomeDirectory = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
        NSURL *configFile = [userHomeDirectory URLByAppendingPathComponent:kDNSCRIPT_CONFIG_FILE_NAME];
                
        NotificationHandler *handler = [[NotificationHandler alloc] init];
        [handler loadConfigFile:configFile];
        [handler startListening];
        
        int queue = kqueue();
        
        const char *cstring_config_path = [[configFile path] cStringUsingEncoding:NSUTF8StringEncoding];
        int config_fd = open(cstring_config_path, O_EVTONLY);
        struct kevent kevp;
        // You'd think just NOTE_WRITE would work, but editing with vim gives
        // NOTE_RENAME and then NOTE_DELETE | NOTE_LINK. So, we register for
        // NOTE_WRITE | NOTE_LINK. Someone else with the same problem:
        // http://stackoverflow.com/questions/8293121/kqueues-on-mac-os-x-strange-event-order
        EV_SET(&kevp, config_fd, EVFILT_VNODE, EV_ADD | EV_CLEAR, NOTE_WRITE | NOTE_LINK, 0, 0);
        
        kevent(queue, &kevp, 1, NULL, 0, NULL);
        struct kevent event;
        while (1) {
            int n = kevent(queue, &kevp, 1, &event, 1, NULL);
            if (n == 1) {
                NSLog(@"%@ changed, reloading...", [configFile path]);
                [handler reloadConfigFile];
                
                // Old file descriptor is no longer valid with the way vim saves
                // (can you tell which program I'm using to test this?)
                close(config_fd);
                config_fd = open(cstring_config_path, O_EVTONLY);
                kevp.ident = config_fd;
            } else {
                NSLog(@"Unexpected value: %d", n);
            }
        }
        close(queue);
        close(config_fd);
    }
    return 0;
}

