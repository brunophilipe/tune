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

	// MARK: - Playback status information

	var currentTrack: MediaPlayerItem? { get }
	var currentPlaylist: MediaPlayerPlaylist? { get }
	var currentPlaybackInfo: MediaPlayerPlaybackInfo? { get }

	// MARK: - Playback control functions

	func playPause()
	func pause()
	func stop()
	func nextTrack()
	func previousTrack()

	// MARK: - Media control functions

	func play(track: MediaPlayerItem)
}

struct MediaPlayerPlaybackInfo
{
	let progress: Double
	let status: PlayerStatus
	let shuffleOn: Bool
	let repeatOn: Bool

	enum PlayerStatus
	{
		case stopped
		case playing
		case paused
		//		case fastForwarding
		//		case rewinding
	}
}

protocol MediaPlayerItem
{
	var kind: MediaPlayerItemKind { get }
	var name: String { get }
	var artist: String { get }
	var album: String { get }

	var year: String? { get }
	var time: Double? { get }
	var index: Int? { get }

	func compare(_ otherItem: MediaPlayerItem?) -> Bool
}

enum MediaPlayerItemKind
{
	case track
	case album
}

protocol MediaPlayerPlaylist
{
	var count: Int { get }
	var name: String? { get }
	var time: Double? { get }

	func item(at index: Int) -> MediaPlayerItem?

	func compare(_ otherPlaylist: MediaPlayerPlaylist?) -> Bool
}

// This is a bit of a hack, because we can't force the protocol to inherit from Equatable,
// but the Swift compiler is smart enough to let the operators be used! Yay!

func ==(_ lhi: MediaPlayerItem?, _ rhi: MediaPlayerItem?) -> Bool
{
	return lhi?.compare(rhi) ?? false
}

func !=(_ lhi: MediaPlayerItem?, _ rhi: MediaPlayerItem?) -> Bool
{
	return !(lhi == rhi)
}

func ==(_ lhp: MediaPlayerPlaylist?, _ rhp: MediaPlayerPlaylist?) -> Bool
{
	return lhp?.compare(rhp) ?? false
}

func !=(_ lhp: MediaPlayerPlaylist?, _ rhp: MediaPlayerPlaylist?) -> Bool
{
	return !(lhp == rhp)
}

