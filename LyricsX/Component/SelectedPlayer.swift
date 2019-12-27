//
//  AppController.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General License for more details.
//
//  You should have received a copy of the GNU General License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import MusicPlayer
import GenericID
import CombineX

extension MusicPlayers {
    
    final class Selected: ObservableObject {
        
        static let shared = MusicPlayers.Selected()
        
        let objectWillChange = ObservableObjectPublisher()
        
        @Published var currentPlayer: MusicPlayerProtocol?
        
        private var cancelBag = Set<AnyCancellable>()
        
        private var defaultsObservation: DefaultsObservation?
        
        var manualUpdateInterval: TimeInterval = 1.0 {
            didSet {
                scheduleManualUpdate()
            }
        }
        
        init() {
            scheduleManualUpdate()
            $currentPlayer
                .map { $0?.objectWillChange.eraseToAnyPublisher() ?? Just(()).eraseToAnyPublisher() }
                .switchToLatest()
                .sink { [weak self] _ in self?.objectWillChange.send() }
                .store(in: &cancelBag)
            defaultsObservation = defaults.observe(.PreferredPlayerIndex, options: [.initial, .new]) { [weak self] _, change in
                if change.newValue == -1 {
                    self?.currentPlayer = MusicPlayers.NowPlaying()
                } else {
                    self?.currentPlayer = MusicPlayerName(index: change.newValue).flatMap(MusicPlayers.ScriptingBridged.init)
                }
            }
        }
        
        private var scheduleCanceller: Cancellable?
        func scheduleManualUpdate() {
            scheduleCanceller?.cancel()
            let q = DispatchQueue.global().cx
            let i: CXWrappers.DispatchQueue.SchedulerTimeType.Stride = .seconds(manualUpdateInterval)
            scheduleCanceller = q.schedule(after: q.now.advanced(by: i), interval: i, tolerance: i * 0.1, options: nil) { [unowned self] in
                self.currentPlayer?.updatePlayerState()
            }
        }
    }
}

extension MusicPlayers.Selected: MusicPlayerProtocol {
    
    var name: MusicPlayerName? {
        return currentPlayer?.name
    }
    
    var currentTrack: MusicTrack? {
        return currentPlayer?.currentTrack
    }
    
    var playbackState: PlaybackState {
        return currentPlayer?.playbackState ?? .stopped
    }
    
    var playbackTime: TimeInterval {
        get { return currentPlayer?.playbackTime ?? 0 }
        set { currentPlayer?.playbackTime = newValue }
    }
    
    var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $currentPlayer.map { $0?.currentTrackWillChange ?? Just(nil).eraseToAnyPublisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $currentPlayer.map { $0?.playbackStateWillChange ?? Just(.stopped).eraseToAnyPublisher() }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
    
    func resume() {
        currentPlayer?.resume()
    }
    
    func pause() {
        currentPlayer?.pause()
    }
    
    func playPause() {
        currentPlayer?.playPause()
    }
    
    func skipToNextItem() {
        currentPlayer?.skipToNextItem()
    }
    
    func skipToPreviousItem() {
        currentPlayer?.skipToPreviousItem()
    }
    
    func updatePlayerState() {
        currentPlayer?.updatePlayerState()
    }
}
