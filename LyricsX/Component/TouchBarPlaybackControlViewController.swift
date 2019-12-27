//
//  TouchBarPlaybackControlItem.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
