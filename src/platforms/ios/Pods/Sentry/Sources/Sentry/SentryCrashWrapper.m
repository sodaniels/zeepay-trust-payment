#import "SentryCrashWrapper.h"
#import "SentryCrash.h"
#import "SentryCrashMonitor_AppState.h"
#import "SentryCrashMonitor_System.h"
#import "SentryHook.h"
#import <Foundation/Foundation.h>
#import <SentryCrashCachedData.h>
#import <SentryCrashDebug.h>
#import <SentryCrashMonitor_System.h>
#include <mach/mach.h>

NS_ASSUME_NONNULL_BEGIN

@implementation SentryCrashWrapper

+ (instancetype)sharedInstance
{
    static SentryCrashWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (BOOL)crashedLastLaunch
{
    return SentryCrash.sharedInstance.crashedLastLaunch;
}

- (NSTimeInterval)activeDurationSinceLastCrash
{
    return SentryCrash.sharedInstance.activeDurationSinceLastCrash;
}

- (BOOL)isBeingTraced
{
    return sentrycrashdebug_isBeingTraced();
}

- (BOOL)isSimulatorBuild
{
    return sentrycrash_isSimulatorBuild();
}

- (BOOL)isApplicationInForeground
{
    return sentrycrashstate_currentState()->applicationIsInForeground;
}

- (void)installAsyncHooks
{
    sentrycrash_install_async_hooks();
}

- (void)close
{
    SentryCrash *handler = [SentryCrash sharedInstance];
    @synchronized(handler) {
        [handler setMonitoring:SentryCrashMonitorTypeNone];
        handler.onCrash = NULL;
    }

    sentrycrash_deactivate_async_hooks();
    sentrycrashccd_close();
}

- (NSDictionary *)systemInfo
{
    static NSDictionary *sharedInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInfo = SentryCrash.sharedInstance.systemInfo; });
    return sharedInfo;
}

- (uint64_t)freeMemory
{
    return sentrycrashcm_system_freememory();
}

- (uint64_t)appMemory
{
    task_vm_info_data_t info;
    mach_msg_type_number_t size = TASK_VM_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&info, &size);
    if (kerr == KERN_SUCCESS) {
        return info.internal + info.compressed;
    }

    return 0;
}

@end

NS_ASSUME_NONNULL_END
