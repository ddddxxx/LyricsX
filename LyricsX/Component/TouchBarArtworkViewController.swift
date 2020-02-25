//
//  TouchBarCurrentPlayingItem.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import AppKit
import CombineX
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
