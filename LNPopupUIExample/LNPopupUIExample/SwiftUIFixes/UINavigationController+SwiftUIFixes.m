//
//  UINavigationController+SwiftUIFixes.m
//  LNPopupUIExample
//
//  Created by Leo Natan on 10/26/20.
//

#import "UINavigationController+SwiftUIFixes.h"
@import ObjectiveC;

@implementation UINavigationController (SwiftUIFixes)

- (void)_ln_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if(self.viewControllers.count > 0)
	{
		viewController.hidesBottomBarWhenPushed = viewController.toolbarItems.count == 0;
	}
	
	[self _ln_pushViewController:viewController animated:animated];
}

- (void)_ln_setToolbarHidden:(BOOL)toolbarHidden
{
	[self setToolbarHidden:self.topViewController.toolbarItems.count == 0 animated:NO];
}

+ (void)load
{
	@autoreleasepool {
		Method m1 = class_getInstanceMethod(self, @selector(pushViewController:animated:));
		Method m2 = class_getInstanceMethod(self, @selector(_ln_pushViewController:animated:));
		
		method_exchangeImplementations(m1, m2);
		
		m1 = class_getInstanceMethod(self, @selector(setToolbarHidden:));
		m2 = class_getInstanceMethod(self, @selector(_ln_setToolbarHidden:));
		
		method_exchangeImplementations(m1, m2);
	}
}

@end
