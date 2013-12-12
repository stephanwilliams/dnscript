#import "ConfigChangeMonitor.h"

@implementation ConfigChangeMonitor

- (id)initWithNotificationHandler:(NotificationHandler *)handler {
    self = [super init];
    if (self) {
        _handler = handler;
    }
    return self;
}

- (void)handlePortMessage:(NSPortMessage *)message {
    NSLog(@"%@ changed, reloading...", [_handler.configFileURL path]);
    [_handler reloadConfigFile];
}

- (void)monitorConfigChangesWithPort:(id)data {
    srcPort = (NSPort *)data;
    
    dstPort = [NSMachPort port];
    [[NSRunLoop currentRunLoop] addPort:dstPort forMode:NSDefaultRunLoopMode];
    
    int queue = kqueue();
    
    const char *cstring_config_path = [[_handler.configFileURL path] cStringUsingEncoding:NSUTF8StringEncoding];
    int config_fd = open(cstring_config_path, O_EVTONLY);
    struct kevent kevp;
    EV_SET(&kevp, config_fd, EVFILT_VNODE, EV_ADD | EV_CLEAR, NOTE_WRITE | NOTE_LINK, 0, 0);
    
    kevent(queue, &kevp, 1, NULL, 0, NULL);
    struct kevent event;
    while (1) {
        int n = kevent(queue, &kevp, 1, &event, 1, NULL);
        if (n == 1) {
            NSPortMessage *message = [[NSPortMessage alloc] initWithSendPort:srcPort receivePort:dstPort components:nil];
            [message sendBeforeDate:[NSDate date]];
            
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

@end
