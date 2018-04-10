//
//  TouchBarPrivateAPI.h
//  LyricsX
//
//  Created by noctis on 2018/4/10.
//  Copyright © 2018年 ddddxxx. All rights reserved.
//

#ifndef TouchBarPrivateAPI_h
#define TouchBarPrivateAPI_h

#import <AppKit/AppKit.h>

extern void DFRElementSetControlStripPresenceForIdentifier(NSTouchBarItemIdentifier, BOOL);

extern void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL);

@interface NSTouchBarItem (PrivateMethods)

+ (void)addSystemTrayItem:(NSTouchBarItem *)item;

+ (void)removeSystemTrayItem:(NSTouchBarItem *)item;

@end

@interface NSTouchBar (PrivateMethods)

// presentSystemModalFunctionBar:placement:systemTrayItemIdentifier:
// v40@0:8@16q24@32
+ (void)presentSystemModalFunctionBar:(NSTouchBar *)touchBar placement:(long long)placement systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier;

+ (void)presentSystemModalFunctionBar:(NSTouchBar *)touchBar systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier;

+ (void)dismissSystemModalFunctionBar:(NSTouchBar *)touchBar;

+ (void)minimizeSystemModalFunctionBar:(NSTouchBar *)touchBar;

@end

#endif /* TouchBarPrivateAPI_h */
