//
//  LNPopupUIExample-Bridging-Header.h
//  LNPopupUIExample
//
//  Created by Léo Natan on 2021-03-20.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

#ifndef LNPopupUIExample_Bridging_Header_h
#define LNPopupUIExample_Bridging_Header_h

#import "Settings/SettingKeys.h"

@interface UIImage ()

+ (instancetype)_systemImageNamed:(NSString*)name NS_SWIFT_NAME(init(_systemName:));
+ (instancetype)_systemImageNamed:(NSString*)name withConfiguration:(nullable UIImageConfiguration *)configuration allowPrivate:(BOOL)allowPrivate;

@end

#endif /* LNPopupUIExample_Bridging_Header_h */
