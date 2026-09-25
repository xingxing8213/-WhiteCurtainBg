ARCHS = arm64
TARGET = iphone:clang:16.5:15.0
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WhiteCurtainBg

WhiteCurtainBg_FILES = Tweak.m
WhiteCurtainBg_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-error
WhiteCurtainBg_FRAMEWORKS = UIKit Foundation

include $(THEOS)/makefiles/tweak.mk
