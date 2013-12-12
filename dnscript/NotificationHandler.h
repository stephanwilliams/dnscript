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
