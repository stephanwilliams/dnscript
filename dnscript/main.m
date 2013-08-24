//
//  main.m
//  dnscript
//
//  Created by Stephan Williams on 8/21/13.
//  Copyright (c) 2013 Stephan Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
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
        
        //TODO: listen for file change events? (kqueue API)
        
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[[NSDate alloc] init]
                                                  interval:0.1
                                                    target:nil
                                                  selector:nil
                                                  userInfo:nil
                                                   repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
    return 0;
}

