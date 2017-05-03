//
//  MediaPlayer.swift
//  tune
//
//  Created by Bruno Philipe on 1/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

protocol MediaPlayer: MediaSearchable
{
	/// Internal identification of this media player, such as "itunes"
	var playerId: String { get }

	// MARK: - Playback control functions

	func playPause()
	func pause()
	func stop()
	func nextTrack()
	func previousTrack()

	// MARK: - Media control functions

	func play(track: SearchResultItem)
}
