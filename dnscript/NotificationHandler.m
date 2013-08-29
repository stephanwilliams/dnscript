//
//  NotificationHandler.m
//  dnscript
//
//  Created by Stephan Williams on 8/22/13.
//  Copyright (c) 2013 Stephan Williams. All rights reserved.
//

#import "NotificationHandler.h"

@implementation NotificationHandler

@synthesize configFileURL = _configFileURL;

- (id)init {
    self = [super init];
    if (self) {
        _configLoadSuccess = NO;
    }
    return self;
}

- (BOOL)listening {
    return _listening;
}

- (void)startListening {
    if (_listening) {
        NSLog(@"Already listening!");
        return;
    }
    if (_configFileURL == nil) {
        NSLog(@"Cannot start listening before loading config!");
        return;
    }
    if (!_configLoadSuccess) {
        NSLog(@"Cannot start listening without successful config load!");
        return;
    }
        if (_dnCenter == nil) _dnCenter = [NSDistributedNotificationCenter defaultCenter];
    
    for (NSString *key in _scriptMap) {
        [_dnCenter addObserver:self selector:@selector(handleNotification:) name:key object:nil];
    }
    _listening = YES;

}

- (void)stopListening {
    if (!_listening) {
        NSLog(@"Listening is already stopped!");
    }
    
    [_dnCenter removeObserver:self];
    
    _listening = NO;
}

- (NSURL *)getConfigFile {
    return _configFileURL;
}

- (void)loadConfigFile:(NSURL *)config {
    _configFileURL = config;
    [self reloadConfigFile];
}

- (void)reloadConfigFile {
    BOOL wasListening = _listening;
    if (wasListening) [self stopListening];
    
    [self _loadConfigFile];
    
    if (wasListening) [self startListening];
}

- (void)_loadConfigFile {
    _configLoadSuccess = NO;
    
    if (_scriptMap == nil) {
        _scriptMap = [[NSMutableDictionary alloc] init];
    } else {
        [_scriptMap removeAllObjects];
    }
    
    NSError *error;
    NSString *config = [NSString stringWithContentsOfURL:_configFileURL encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error while loading config file: %@", error);
        return;
    }
    NSArray *lines = [config componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    unichar prev;
    NSMutableArray *tempNotification = [[NSMutableArray alloc] init];
    NSMutableArray *tempScripts = [[NSMutableArray alloc] init];
    
    for (NSString *line in lines) {
        if (line.length == 0) continue;
        
        unichar curr = [line characterAtIndex:0];
        switch (curr) {
            case '#':
                break;
            case ';':
                if (prev != ';') {
                    [self addScripts:tempScripts forNotifications:tempNotification];
                    [tempNotification removeAllObjects];
                    [tempScripts removeAllObjects];
                }
                [tempNotification addObject:[line substringFromIndex:1]];
                break;
            default:
                [tempScripts addObject:line];
                break;
        }
        prev = curr;
    }
    [self addScripts:tempScripts forNotifications:tempNotification];
//    NSLog(@"%@", _scriptMap);
    _configLoadSuccess = YES;
}

- (void)addScripts:(NSArray *)scripts forNotifications:(NSArray *)notifications {
    for (NSString *notification in notifications) {
        if ([_scriptMap objectForKey:notification] == nil) {
            NSMutableArray *notifArray = [NSMutableArray arrayWithArray:scripts];
            [_scriptMap setObject:notifArray forKey:notification];
        } else {
            NSMutableArray *notifArray = [_scriptMap objectForKey:notification];
            [notifArray addObjectsFromArray:scripts];
        }
    }
}

- (void)handleNotification:(NSNotification *) notification {
    NSArray *scripts = [_scriptMap objectForKey:notification.name];
    for (NSString *script in scripts) {
        [NSTask launchedTaskWithLaunchPath:@"/bin/sh"
                                 arguments:[NSArray arrayWithObjects:
                                            @"-c",
                                            script,
                                            nil]];
    }
}

@end
