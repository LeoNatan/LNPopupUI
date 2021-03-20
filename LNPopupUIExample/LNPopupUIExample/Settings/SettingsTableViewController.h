//
//  SettingsTableViewController.h
//  LNPopupUIExample
//
//  Created by Leo Natan on 3/19/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const PopupSettingsBarStyle;
extern NSString* const PopupSettingsInteractionStyle;
extern NSString* const PopupSettingsProgressViewStyle;
extern NSString* const PopupSettingsCloseButtonStyle;
extern NSString* const PopupSettingsMarqueeStyle;
extern NSString* const PopupSettingsEnableCustomizations;
extern NSString* const PopupSettingsExtendBar;
extern NSString* const PopupSettingsHidesBottomBarWhenPushed;
extern NSString* const PopupSettingsVisualEffectViewBlurEffect;

@interface SettingsTableViewController : UITableViewController

+ (instancetype)newSettingsTableViewController;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
