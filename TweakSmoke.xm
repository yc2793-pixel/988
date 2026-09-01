#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import <dlfcn.h>
#import <time.h>

%group AccSmokeClock

%hookf(int, clock_gettime, clockid_t clk_id, struct timespec *tp) {
    // Smoke test: hook exists, but return exactly what the original function returned.
    return %orig(clk_id, tp);
}

%end

static void HookClockGetTime(void) {
    void *libSystem = dlopen("/usr/lib/libSystem.dylib", RTLD_NOLOAD);
    if (!libSystem) libSystem = dlopen("/usr/lib/libSystem.B.dylib", RTLD_NOLOAD);
    if (!libSystem) libSystem = RTLD_DEFAULT;

    void *fn = dlsym(libSystem, "clock_gettime");
    if (fn) {
        %init(AccSmokeClock, clock_gettime = fn);
    }
}

static void DidFinishLaunching(CFNotificationCenterRef center,
                               void *observer,
                               CFStringRef name,
                               const void *object,
                               CFDictionaryRef userInfo) {
    HookClockGetTime();
}

%ctor {
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetLocalCenter(),
        NULL,
        DidFinishLaunching,
        (CFStringRef)UIApplicationDidFinishLaunchingNotification,
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );
}
