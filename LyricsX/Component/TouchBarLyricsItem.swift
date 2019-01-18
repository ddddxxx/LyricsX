//
//  TouchBarLyricsItem.swift
//  LyricsX
//
//  Created by 邓翔 on 2019/1/17.
//  Copyright © 2019 ddddxxx. All rights reserved.
//

import AppKit
import OpenCC

@available(OSX 10.12.2, *)
class TouchBarLyricsItem: NSCustomTouchBarItem {
    
    private var lyricsTextField = KaraokeLabel(labelWithString: "")
    
    @objc dynamic var progressColor = #colorLiteral(red: 0, green: 1, blue: 0.8333333333, alpha: 1)
    
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        view.addSubview(lyricsTextField)
        lyricsTextField.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            // For some reason the left edge get clipped without the offset.
            make.left.equalToSuperview().offset(4)
        }
        lyricsTextField.alignment = .center
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .lyricsShouldDisplay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .currentLyricsChange, object: nil)
    }
    
    @objc func handleLyricsDisplay() {
        guard let lyrics = AppController.shared.currentLyrics,
            let index = AppController.shared.currentLineIndex else {
                DispatchQueue.main.async {
                    self.lyricsTextField.stringValue = ""
                    self.lyricsTextField.removeProgressAnimation()
                }
                return
        }
        let line = lyrics.lines[index]
        var lyricsContent = line.content
        if let converter = ChineseConverter.shared,
            lyrics.metadata.language?.hasPrefix("zh") == true {
            lyricsContent = converter.convert(lyricsContent)
        }
        DispatchQueue.main.async {
            self.lyricsTextField.stringValue = lyricsContent
            if let timetag = line.attachments.timetag,
                let position = AppController.shared.playerManager.player?.playerPosition {
                let timeDelay = line.lyrics?.adjustedTimeDelay ?? 0
                let progress = timetag.tags.map { ($0.timeTag + line.position - timeDelay - position, $0.index) }
                self.lyricsTextField.setProgressAnimation(color: self.progressColor, progress: progress)
            }
        }
    }
}
