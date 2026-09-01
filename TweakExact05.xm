#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import <dlfcn.h>
#import <time.h>

static time_t pre_sec = 0;
static long pre_nsec = 0;
static time_t true_pre_sec = 0;
static long true_pre_nsec = 0;

#define NSec_Scale (1000000000LL)
#define FIXED_RATE (0.50)

%group AccExactClock

%hookf(int, clock_gettime, clockid_t clk_id, struct timespec *tp) {
    int ret = %orig(clk_id, tp);

    if (!ret) {
        if (!pre_sec) {
            pre_sec = tp->tv_sec;
            true_pre_sec = tp->tv_sec;
            pre_nsec = tp->tv_nsec;
            true_pre_nsec = tp->tv_nsec;
        } else {
            int64_t true_curSec =
                (int64_t)tp->tv_sec * NSec_Scale + (int64_t)tp->tv_nsec;

            int64_t true_preSec =
                (int64_t)true_pre_sec * NSec_Scale + (int64_t)true_pre_nsec;

            int64_t invl = true_curSec - true_preSec;

            // AccDemo original does: invl *= rates[rate_i].
            // This test fixes that rate at 0.50x.
            invl = (int64_t)((double)invl * FIXED_RATE);

            int64_t curSec =
                (int64_t)pre_sec * NSec_Scale + (int64_t)pre_nsec;

            curSec += invl;

            time_t used_sec = (time_t)(curSec / NSec_Scale);
            long used_nsec = (long)(curSec % NSec_Scale);

            true_pre_sec = tp->tv_sec;
            true_pre_nsec = tp->tv_nsec;

            tp->tv_sec = used_sec;
            tp->tv_nsec = used_nsec;

            pre_sec = used_sec;
            pre_nsec = used_nsec;
        }
    }

    return ret;
}

%end

static void HookClockGetTime(void) {
    void *libSystem = dlopen("/usr/lib/libSystem.dylib", RTLD_NOLOAD);
    if (!libSystem) libSystem = dlopen("/usr/lib/libSystem.B.dylib", RTLD_NOLOAD);
    if (!libSystem) libSystem = RTLD_DEFAULT;

    void *fn = dlsym(libSystem, "clock_gettime");
    if (fn) {
        %init(AccExactClock, clock_gettime = fn);
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
