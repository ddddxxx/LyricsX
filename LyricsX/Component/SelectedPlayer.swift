//
//  AppController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import MusicPlayer
import GenericID
import CombineX

extension MusicPlayers {
    
    final class Selected: Delegate {
        
        static let shared = MusicPlayers.Selected()
        
        private var defaultsObservation: DefaultsObservation?
        
        var manualUpdateInterval: TimeInterval = 1.0 {
            didSet {
                scheduleManualUpdate()
            }
        }
        
        override init() {
            super.init()
            scheduleManualUpdate()
            defaultsObservation = defaults.observe(.PreferredPlayerIndex, options: [.initial, .new]) { [weak self] _, change in
                if change.newValue == -1 {
                    let players = MusicPlayerName.scriptableCases.compactMap(MusicPlayers.Scriptable.init)
                    self?.designatedPlayer = MusicPlayers.NowPlaying(players: players)
                } else {
                    self?.designatedPlayer = MusicPlayerName(index: change.newValue).flatMap(MusicPlayers.Scriptable.init)
                }
            }
        }
        
        private var scheduleCanceller: Cancellable?
        func scheduleManualUpdate() {
            scheduleCanceller?.cancel()
            guard manualUpdateInterval > 0 else { return }
            let q = DispatchQueue.global().cx
            let i: CXWrappers.DispatchQueue.SchedulerTimeType.Stride = .seconds(manualUpdateInterval)
            scheduleCanceller = q.schedule(after: q.now.advanced(by: i), interval: i, tolerance: i * 0.1, options: nil) { [unowned self] in
                self.designatedPlayer?.updatePlayerState()
            }
        }
    }
}
