//
//  AppController.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import MusicPlayer
import GenericID
import CXShim

extension MusicPlayers {
    
    final class Selected: Agent {
        
        static let shared = MusicPlayers.Selected()
        
        private var defaultsObservation: DefaultsObservation?
        
        private var manualUpdateObservation: AnyCancellable?
        
        var manualUpdateInterval: TimeInterval = 1.0 {
            didSet {
                scheduleManualUpdate()
            }
        }
        
        override init() {
            super.init()
            selectPlayer()
            scheduleManualUpdate()
            defaultsObservation = defaults.observe(keys: [.preferredPlayerIndex, .useSystemWideNowPlaying]) { [weak self] in
                self?.selectPlayer()
            }
            manualUpdateObservation = playbackStateWillChange.sink { [weak self] state in
                if state.isPlaying {
                    self?.scheduleManualUpdate()
                } else {
                    self?.scheduleCanceller?.cancel()
                }
            }
        }
        
        private func selectPlayer() {
            let idx = defaults[.preferredPlayerIndex]
            if idx == -1 {
                if defaults[.useSystemWideNowPlaying] {
                    designatedPlayer = MusicPlayers.SystemMedia()
                } else {
                    let players = MusicPlayerName.scriptableCases.compactMap(MusicPlayers.Scriptable.init)
                    designatedPlayer = MusicPlayers.NowPlaying(players: players)
                }
            } else {
                designatedPlayer = MusicPlayerName(index: idx).flatMap(MusicPlayers.Scriptable.init)
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
