//
//  TouchBarPrivateAPI.h
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#ifndef TouchBarPrivateAPI_h
#define TouchBarPrivateAPI_h

#import <AppKit/AppKit.h>

@interface NSTouchBarItem (PrivateMethods)

+ (void)addSystemTrayItem:(NSTouchBarItem *)item;

+ (void)removeSystemTrayItem:(NSTouchBarItem *)item;

@end

@interface NSTouchBar (PrivateMethods)

// MARK: macOS 10.14 and above

+ (void)presentSystemModalTouchBar:(NSTouchBar *)touchBar placement:(long long)placement systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier NS_AVAILABLE_MAC(10.14);

+ (void)presentSystemModalTouchBar:(NSTouchBar *)touchBar systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier NS_AVAILABLE_MAC(10.14);

+ (void)dismissSystemModalTouchBar:(NSTouchBar *)touchBar NS_AVAILABLE_MAC(10.14);

+ (void)minimizeSystemModalTouchBar:(NSTouchBar *)touchBar NS_AVAILABLE_MAC(10.14);

// MARK: macOS 10.13 and below

+ (void)presentSystemModalFunctionBar:(NSTouchBar *)touchBar placement:(long long)placement systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier NS_DEPRECATED_MAC(10.12.2, 10.14);

+ (void)presentSystemModalFunctionBar:(NSTouchBar *)touchBar systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier NS_DEPRECATED_MAC(10.12.2, 10.14);

+ (void)dismissSystemModalFunctionBar:(NSTouchBar *)touchBar NS_DEPRECATED_MAC(10.12.2, 10.14);

+ (void)minimizeSystemModalFunctionBar:(NSTouchBar *)touchBar NS_DEPRECATED_MAC(10.12.2, 10.14);

@end

#endif /* TouchBarPrivateAPI_h */
