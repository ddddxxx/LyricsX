//
//  TouchBarPlaybackControlItem.swift
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
import MusicPlayer
import CombineX

@available(OSX 10.12.2, *)
class TouchBarPlaybackControlViewController: NSViewController {
    
    private weak var segmentedControl: NSSegmentedControl!
    
    private var cancelBag = Set<AnyCancellable>()
    
    override func loadView() {
        let rewindImage = NSImage(named: NSImage.touchBarRewindTemplateName)!
        let playPauseImage = NSImage(named: NSImage.touchBarPlayTemplateName)!
        let fastForwardImage = NSImage(named: NSImage.touchBarFastForwardTemplateName)!
        let seg = NSSegmentedControl()
        seg.trackingMode = .momentary
        seg.segmentCount = 3
        seg.setImage(rewindImage, forSegment: 0)
        seg.setImage(playPauseImage, forSegment: 1)
        seg.setImage(fastForwardImage, forSegment: 2)
        seg.target = self
        seg.action = #selector(segmentAction)
        
        self.view = seg
        self.segmentedControl = seg
        
        selectedPlayer.playbackStateWillChange
            .receive(on: DispatchQueue.main.cx)
            .sink { [weak self] state in
                let image = state.isPlaying
                    ? NSImage(named: NSImage.touchBarPauseTemplateName)
                    : NSImage(named: NSImage.touchBarPlayTemplateName)
                self?.segmentedControl?.setImage(image, forSegment: 1)
            }.store(in: &cancelBag)
    }
    
    @IBAction func segmentAction(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0: rewindAction(nil)
        case 1: playPauseAction(nil)
        case 2: fastForwardAction(nil)
        default: break
        }
    }
    
    @IBAction func rewindAction(_ sender: Any?) {
        if selectedPlayer.playbackTime > 5 {
            selectedPlayer.playbackTime = 0
        } else {
            selectedPlayer.skipToPreviousItem()
        }
    }
    
    @IBAction func playPauseAction(_ sender: Any?) {
        selectedPlayer.playPause()
    }
    
    @IBAction func fastForwardAction(_ sender: Any?) {
        selectedPlayer.skipToNextItem()
    }
}
