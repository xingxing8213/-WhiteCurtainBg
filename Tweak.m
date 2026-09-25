#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

static const CGFloat kBgAlpha = 0.5;

static void applyWhiteToView(UIView *view) {
    if (!view) return;
    @try {
        NSString *cls = NSStringFromClass(view.class);
        if ([cls containsString:@"MTMaterial"] ||
            [cls containsString:@"GainMap"]    ||
            [cls containsString:@"Backdrop"]) {
            view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:kBgAlpha];
        }
        for (UIView *sub in view.subviews) {
            applyWhiteToView(sub);
        }
    } @catch (NSException *e) {}
}

static void setupTimer(void) {
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *t) {
        @autoreleasepool {
            for (UIWindow *w in [UIApplication sharedApplication].windows) {
                if ([NSStringFromClass(w.class) containsString:@"SystemAperture"]) {
                    applyWhiteToView(w.rootViewController.view);
                }
            }
        }
    }];
}

static void hookSpringBoardLaunch(void) {
    Class sbClass = NSClassFromString(@"SpringBoard");
    if (!sbClass) return;
    SEL origSel = @selector(applicationDidFinishLaunching:);
    Method origMethod = class_getInstanceMethod(sbClass, origSel);
    if (!origMethod) return;
    IMP origImp = method_getImplementation(origMethod);
    IMP newImp = imp_implementationWithBlock(^(id _self, id application) {
        ((void (*)(id, SEL, id))origImp)(_self, origSel, application);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{ setupTimer(); });
    });
    method_setImplementation(origMethod, newImp);
}

__attribute__((constructor))
static void constructor(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ hookSpringBoardLaunch(); });
}
