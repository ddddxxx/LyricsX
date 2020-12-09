//
//  TouchBarCurrentPlayingItem.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AppKit
import CXShim
import MusicPlayer

class TouchBarArtworkViewController: NSViewController {
    
    let artworkView = NSImageView()
    
    private var cancelBag = Set<AnyCancellable>()
    
    override func loadView() {
        view = artworkView
    }
    
    override func viewDidLoad() {
        selectedPlayer.currentTrackWillChange
            .signal()
            .receive(on: DispatchQueue.main.cx)
            .invoke(TouchBarArtworkViewController.updateArtworkImage, weaklyOn: self)
            .store(in: &cancelBag)
        updateArtworkImage()
    }
    
    func updateArtworkImage() {
        if let image = selectedPlayer.currentTrack?.artwork ?? selectedPlayer.name?.icon {
            let size = CGSize(width: 30, height: 30)
            self.artworkView.image = NSImage(size: size, flipped: false) { rect in
                image.draw(in: rect)
                return true
            }
        } else {
            // TODO: Placeholder
            self.artworkView.image = nil
        }
    }
}
