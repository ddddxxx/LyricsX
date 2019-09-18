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
import PlaybackControl
import SnapKit

@available(OSX 10.12.2, *)
class TouchBarPlaybackControlViewController: NSViewController {
    
    override func loadView() {
        let rewindImage = NSImage(named: NSImage.touchBarRewindTemplateName)!
        let rewindButton = NSButton(image: rewindImage, target: self, action: #selector(rewindAction(_:)))
        let playPauseImage = NSImage(named: NSImage.touchBarPlayPauseTemplateName)!
        let playPauseButton = NSButton(image: playPauseImage, target: self, action: #selector(playPauseAction(_:)))
        let fastForwardImage = NSImage(named: NSImage.touchBarFastForwardTemplateName)!
        let fastForwardButton = NSButton(image: fastForwardImage, target: self, action: #selector(fastForwardAction(_:)))
        view = NSView()
        view.addSubview(rewindButton)
        view.addSubview(playPauseButton)
        view.addSubview(fastForwardButton)
        rewindButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(playPauseButton.snp.width)
            make.width.equalTo(fastForwardButton.snp.width)
            make.width.equalTo(50)
        }
        playPauseButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(rewindButton.snp.right).offset(2)
            make.right.equalTo(fastForwardButton.snp.left).offset(-2)
        }
        fastForwardButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
        }
    }
    
    @IBAction func rewindAction(_ sender: Any?) {
        guard let player = AppController.shared.playerManager.player else {
            return
        }
        if player.playbackTime > 5 {
            player.playbackTime = 0
        } else {
            player.skipToPreviousItem()
        }
    }
    
    @IBAction func playPauseAction(_ sender: Any?) {
        AppController.shared.playerManager.player?.playPause()
    }
    
    @IBAction func fastForwardAction(_ sender: Any?) {
        AppController.shared.playerManager.player?.skipToNextItem()
    }
}
