//
//  iTunesHandler.swift
//  tune
//
//  Created by Bruno Philipe on 7/25/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
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

import Foundation
import ScriptingBridge
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

let kUnknownArtist = "Unknown Artist"
let kUnknownTrack = "Unknown Track"
let kUnknownAlbum = "Unknown Album"

typealias Verb = (names: [String], brief: String, description: [String], extra: String?)

class iTunesHandler
{
	var currentTrack: MediaPlayerItem?
	{
		if let track = iTunesApp?.currentTrack, track.duration > 0
		{
			return iTunesTrackMediaItem(track: track)
		}
		else
		{
			return nil
		}
	}
	
	var currentPlaylist: MediaPlayerPlaylist?
	{
		if let track = iTunesApp?.currentTrack, track.duration > 0,
		   let playlist = track.container?.get() as? iTunesPlaylist, playlist.id!() > 0
		{
			// This returns a playlist that's more likely to have the correct track `index` property, since it depends on the sorting.
			return iTunesMediaPlaylist(playlist: playlist)
		}
		else if let playlist = iTunesApp?.currentPlaylist?.get() as? iTunesPlaylist, playlist.id!() > 0
		{
			return iTunesMediaPlaylist(playlist: playlist)
		}
		else if let playlist = iTunesApp?.currentPlaylist
		{
			return iTunesMediaPlaylist(playlist: playlist)
		}
		else
		{
			return nil
		}
	}

	var currentPlaybackInfo: MediaPlayerPlaybackInfo?
	{
		if let iTunesApp = self.iTunesApp,
		   let progress = iTunesApp.playerPosition,
		   let status = iTunesApp.playerState,
		   let shuffle = iTunesApp.shuffleEnabled
		{
			let repeatOn = iTunesApp.songRepeat != .off

			return MediaPlayerPlaybackInfo(progress: progress, status: .init(status), shuffleOn: shuffle, repeatOn: repeatOn)
		}
		else
		{
			return nil
		}
	}

	fileprivate var iTunesApp: iTunesApplication?

	init()
	{
		iTunesApp = SBApplication(bundleIdentifier: "com.apple.iTunes")

		iTunesApp?.setFixedIndexing!(true)
	}

	fileprivate func runTrackSearch(_ searchString: String) -> [MediaPlayerItem]
	{
		if searchString.characters.count == 0
		{
			return []
		}
		
		if let libraryPlaylist = getLibraryPlaylist()
		{
			let results = libraryPlaylist.searchFor!(searchString, only: .all)
			
			if results.count == 0
			{
				return []
			}

			var processedResults = [MediaPlayerItem]()
			
			for result in results
			{
				if let track = result as? iTunesTrack
				{
					processedResults.append(iTunesTrackMediaItem(track: track))
				}
			}

			return processedResults
		}
		else
		{
			return []
		}
	}
	
	fileprivate func runAlbumSearch(_ searchString: String)
	{
		if let libraryPlaylist = getLibraryPlaylist()
		{
			let results = libraryPlaylist.searchFor!(searchString, only: .all)
			var albums: [(human: String, query: String)] = []
			
			for result in results
			{
				if let track = result as? iTunesTrack,
					let albumDesc = track.prettyAlbumDescription,
					let albumQuery = track.searchableAlbumDescription,
					!albums.contains(where:
						{
							entry in

							return albumQuery == entry.query
						})
				{
					albums.append((albumDesc, albumQuery))
				}
			}

			/*
			
			print("\nInsert value [1-\(displayCount)] to pick album to play or 0 to cancel: ")
			
			if let input = getUserInput(), let number = Int(input)
			{
				if number == 0
				{
					print("Exiting on user request.")
					return
				}
				else if number > 0 && number <= displayCount
				{
					let album = albums[number-1].query
					let albumResults = libraryPlaylist.searchFor!(album, only: .all)
					
					if albumResults.count > 0, let queue = getQueuePlaylist()
					{
						for i in 0 ..< results.count
						{
							let track = results[i] as! iTunesTrack
							if track.searchableAlbumDescription == albums[number-1].query
							{
								_ = track.duplicateTo!(queue as! SBObject)
							}
						}
						
						queue.playOnce!(true)
						
						print("Now playing \(albums[number-1].human). Enjoy the music!")
						return
					}
					else
					{
						print("Could not load album... Exiting.")
						return
					}
				}
				else
				{
					print("Invalid user input \"\(number)\". Exiting.")
					return
				}
			}

			*/
			
			print("Invalid user input.. Exiting.")
			return
		}
		else
		{
			print("Could not get iTunes library!\n")
		}
	}
	
	fileprivate func getLibraryPlaylist() -> iTunesLibraryPlaylist?
	{
		var librarySource: iTunesSource? = nil
		
		for sourceElement in iTunesApp?.sources!() as SBElementArray!
		{
			if let source = sourceElement as? iTunesSource, source.kind == .library
			{
				librarySource = source
				break
			}
		}
		
		if librarySource == nil
		{
			return nil
		}
		
		for playlistElement in librarySource?.playlists!() as SBElementArray!
		{
			if let playlist = playlistElement as? iTunesPlaylist, playlist.specialKind == .library,
			   let libraryPlaylist = playlist.get() as? iTunesLibraryPlaylist
			{
				return libraryPlaylist
			}
		}
		
		return nil
	}
	
	fileprivate func getQueuePlaylist() -> iTunesPlaylist?
	{
		var librarySource: iTunesSource? = nil
		
		for sourceElement in iTunesApp?.sources!() as SBElementArray!
		{
			if let source = sourceElement as? iTunesSource, source.kind == .library
			{
				librarySource = source
				break
			}
		}
		
		if librarySource == nil
		{
			return nil
		}
		
		// Try using existing playlist
		for playlistElement in librarySource?.playlists!() as SBElementArray!
		{
			if let playlist = playlistElement as? iTunesPlaylist, playlist.name == "tune"
			{
				let tracks = playlist.tracks!() as NSMutableArray
				tracks.removeAllObjects()
				
				return playlist
			}
		}
		
		// Create new playlist
		if let object = iTunesTools.instantiateObject(from: iTunesApp as! SBApplication,
		                                              typeName: "playlist",
		                                              andProperties: ["name": "tune", "visible": false])
		{
			let playlists = (librarySource?.playlists!() as SBElementArray!) as NSMutableArray
			playlists.add(object)
			
			return object as iTunesPlaylist
		}
		
		return nil
	}
}

private extension MediaPlayerPlaybackInfo.PlayerStatus
{
	/// Maps from an iTunes internal `iTunesEPlS` type to the generic `MediaPlayerPlaybackInfo.PlayerStatus` type.
	init(_ status: iTunesEPlS)
	{
		switch status
		{
		case .playing: self = .playing
		case .paused:  self = .paused
		case .stopped: self = .stopped

		// The MediaPlayer protocol doesn't yet support advanced states
		default: self = .playing
		}
	}
}

extension iTunesHandler: MediaPlayer
{
	/// Internal identification of this media player, such as "itunes"
	var playerId: String
	{
		return "itunes"
	}

	// MARK: - Playback control functions

	func playPause()
	{
		iTunesApp?.playpause!()
	}

	func pause()
	{
		iTunesApp?.pause!()
	}

	func stop()
	{
		iTunesApp?.stop!()
	}

	func nextTrack()
	{
		iTunesApp?.nextTrack!()
	}

	func previousTrack()
	{
		iTunesApp?.previousTrack!()
	}

	func search(forTracks text: String) -> SearchResult
	{
		return SearchResult(withItems: runTrackSearch(text), forQuery: text)
	}

	func search(forAlbums text: String) -> SearchResult
	{
		return SearchResult(withItems: [], forQuery: text)
	}

	func search(forPlaylists text: String) -> SearchResult
	{
		return SearchResult(withItems: [], forQuery: text)
	}

	// MARK: - Media control functions

	func play(track: MediaPlayerItem)
	{
		if let iTunesItem = track as? iTunesTrackMediaItem
		{
			iTunesItem.track.playOnce!(true)
		}
	}
}

func pprint(_ string: String)
{
	print(string.replacingOccurrences(of: "\t", with: "        "))
}

struct iTunesTrackMediaItem: MediaPlayerItem
{
	fileprivate let track: iTunesTrack

	fileprivate init(track: iTunesTrack)
	{
		self.track = track
	}

	var kind: MediaPlayerItemKind
	{
		return .track
	}

	var name: String
	{
		return track.name ?? kUnknownTrack
	}

	var artist: String
	{
		return track.artist ?? kUnknownArtist
	}

	var album: String
	{
		return track.album ?? kUnknownAlbum
	}

	var time: Double?
	{
		return track.duration
	}

	var index: Int?
	{
		return track.index
	}

	var year: String?
	{
		if let year = track.year, year > 0
		{
			return "\(year)"
		}
		else
		{
			return nil
		}
	}

	func compare(_ otherItem: MediaPlayerItem?) -> Bool
	{
		if let otherItem = otherItem, otherItem.kind == kind, let otherTrack = (otherItem as? iTunesTrackMediaItem)?.track
		{
			return otherTrack.persistentID == track.persistentID
		}

		return false
	}
}

struct iTunesAlbumMediaItem: MediaPlayerItem
{
	var kind: MediaPlayerItemKind
	{
		return .album
	}

	var name: String
	{
		return ""
	}

	var artist: String
	{
		return ""
	}

	var album: String
	{
		return ""
	}

	var year: String?
	{
		return ""
	}

	var time: Double?
	{
		return nil
	}

	var index: Int?
	{
		return nil
	}

	func compare(_ otherItem: MediaPlayerItem?) -> Bool
	{
		return false
	}
}

struct iTunesMediaPlaylist: MediaPlayerPlaylist
{
	fileprivate let playlist: iTunesPlaylist

	fileprivate init(playlist: iTunesPlaylist)
	{
		self.playlist = playlist
	}

	var name: String?
	{
		return playlist.name
	}

	var count: Int
	{
		return playlist.tracks?().count ?? 0
	}

	var time: Double?
	{
		if let duration = playlist.duration
		{
			return Double(duration)
		}
		else
		{
			return nil
		}
	}

	func item(at index: Int) -> MediaPlayerItem?
	{
		if let tracks = playlist.tracks?(), index < tracks.count, let track = tracks.object(at: index) as? iTunesTrack
		{
			return iTunesTrackMediaItem(track: track)
		}
		else
		{
			return nil
		}
	}

	func compare(_ otherPlaylist: MediaPlayerPlaylist?) -> Bool
	{
		return (otherPlaylist as? iTunesMediaPlaylist)?.playlist.persistentID == playlist.persistentID
	}
}

private extension iTunesTrack
{
	var prettyAlbumDescription: String?
	{
		var artistName = self.artist

		if artistName == nil || artistName == ""
		{
			artistName = kUnknownArtist
		}
		
		if let albumName = self.album, albumName.characters.count > 0
		{
			let yearString = ((year != nil && year != 0) ? " (\(year!))" : "")
			
			return "\"\(albumName)\" by \(artistName!)\(yearString)"
		}
		else
		{
			return nil
		}
	}
	
	var searchableAlbumDescription: String?
	{
		var string = ""
		
		let artistName = self.artist
		if artistName != nil && artistName != ""
		{
			string += artistName! + " "
		}
		
		let albumName = self.album
		if albumName != nil && albumName != ""
		{
			string += albumName! + " "
		}
		
		if string == ""
		{
			return nil
		}
		else
		{
			return string
		}
	}
}
