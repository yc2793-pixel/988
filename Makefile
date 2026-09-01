ARCHS = arm64
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AccDemoSmoke AccDemoExact05

AccDemoSmoke_FILES = TweakSmoke.xm
AccDemoSmoke_FRAMEWORKS = UIKit Foundation
AccDemoSmoke_LIBRARIES = substrate
AccDemoSmoke_CFLAGS = -fobjc-arc
AccDemoSmoke_LDFLAGS = -Wl,-dead_strip

AccDemoExact05_FILES = TweakExact05.xm
AccDemoExact05_FRAMEWORKS = UIKit Foundation
AccDemoExact05_LIBRARIES = substrate
AccDemoExact05_CFLAGS = -fobjc-arc
AccDemoExact05_LDFLAGS = -Wl,-dead_strip

include $(THEOS_MAKE_PATH)/tweak.mk
