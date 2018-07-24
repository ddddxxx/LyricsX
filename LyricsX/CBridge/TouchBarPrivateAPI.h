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
