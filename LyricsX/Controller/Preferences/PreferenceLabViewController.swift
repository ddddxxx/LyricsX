//
//  PreferenceLabViewController.swift
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

import Cocoa

class PreferenceLabViewController: NSViewController {
    
    @IBOutlet weak var enableTouchBarLyricsButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if IS_FOR_MAS
            enableTouchBarLyricsButton.target = self
            enableTouchBarLyricsButton.action = #selector(mas_enableTouchBarLyricsAction)
        #else
            enableTouchBarLyricsButton.bind(.value, withDefaultName: .TouchBarLyricsEnabled)
        #endif
    }
    
    @IBAction func mas_enableTouchBarLyricsAction(_ sender: NSButton) {
        sender.state = .off
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Unable to enable Touch Bar lyrics.", comment: "alert title")
        alert.informativeText = NSLocalizedString("Touch Bar lyrics is not supported in Mac App Store Version. Please download on GitHub.", comment: "")
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Download", comment: ""))
        let handler = { (response: NSApplication.ModalResponse) in
            if response == .alertSecondButtonReturn {
                let url = URL(string: "https://github.com/XQS6LB3A/LyricsX/releases")!
                NSWorkspace.shared.open(url)
            }
        }
        if let window = view.window {
            alert.beginSheetModal(for: window, completionHandler: handler)
        } else {
            handler(alert.runModal())
        }
    }
}
