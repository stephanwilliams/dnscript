#import <Foundation/Foundation.h>
#import "NotificationHandler.h"
#import "ConfigChangeMonitor.h"

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
        
        ConfigChangeMonitor *monitor = [[ConfigChangeMonitor alloc] initWithNotificationHandler:handler];
        
        NSPort *port = [NSMachPort port];
        [port setDelegate:monitor];
        [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
        [NSThread detachNewThreadSelector:@selector(monitorConfigChangesWithPort:) toTarget:monitor withObject:port];
        while (1) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
    }
    return 0;
}

