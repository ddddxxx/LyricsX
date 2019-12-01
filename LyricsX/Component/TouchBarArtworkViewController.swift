//
//  TouchBarCurrentPlayingItem.swift
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
        defaultNC.cx.publisher(for: MusicPlayerController.currentTrackDidChangeNotification, object: AppController.shared.playerManager)
            .sink { [unowned self] _ in
                let player = AppController.shared.playerManager.player
                self.artworkView.image = player?.currentTrack?.artwork ?? player?.icon
            }.store(in: &cancelBag)
    }
}

extension MusicPlayerController {
    
    var icon: NSImage? {
        switch self {
        case is iTunes: return #imageLiteral(resourceName: "iTunes_icon")
        case is Spotify: return #imageLiteral(resourceName: "spotify_icon")
        case is Vox: return #imageLiteral(resourceName: "vox_icon")
        case is Audirvana: return #imageLiteral(resourceName: "audirvana_icon")
        default: return nil
        }
    }
}
