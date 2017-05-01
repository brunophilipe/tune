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
	var currentTrack: iTunesTrack?
	{
		if let track = iTunesApp?.currentTrack, track.duration > 0
		{
			return track
		}
		else
		{
			return nil
		}
	}
	
	var currentPlaylist: iTunesPlaylist?
	{
		return iTunesApp?.currentPlaylist
	}

	var currentPlaybackInfo: iTunesPlaybackInfo?
	{
		if let iTunesApp = self.iTunesApp, let progress = iTunesApp.playerPosition, let status = iTunesApp.playerState
		{
			return iTunesPlaybackInfo(progress: progress, status: status)
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
	}

	/*
	
	fileprivate func runParser(_ arguments: [String]) -> Bool
	{
		if arguments.count < 2
		{
			return false
		}
		
		switch arguments[1]
		{
		case "help":
			printUsage()
			
		case "play":
			iTunesApp?.playpause!()
			
		case "pause":
			iTunesApp?.pause!()
			
		case "stop":
			iTunesApp?.stop!()
			
		case "next", "n":
			iTunesApp?.nextTrack!()
			
		case "prev", "p", "previous":
			iTunesApp?.previousTrack!()
			
		case "search", "s":
			runTrackSearch(arguments)
			
		case "album", "a":
			runAlbumSearch(arguments)
			
		case "info", "i":
			printCurrentTrackInfo()
			
		default:
			return false
		}
		
		return true
	}

	*/
	
	fileprivate func runTrackSearch(_ searchString: String) -> [SearchResultItem]
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

			var processedResults = [SearchResultItem]()
			
			for result in results
			{
				if let track = result as? iTunesTrack
				{
					processedResults.append(iTunesTrackSearchResult(track: track))
				}
			}

			/*
			
			if let input = getUserInput()
			{
				if input == "a", let queue = getQueuePlaylist()
				{
					for i in 0 ..< displayCount
					{
						if let track = results[i] as? iTunesTrack
						{
							_ = track.duplicateTo!(queue as! SBObject)
						}
					}
					
					queue.playOnce!(true)
					
					print("Playing all results as a queue. Enjoy the music!")
					return
				}
				else if let number = Int(input)
				{
					if number == 0
					{
						print("Exiting on user request.")
						return
					}
					else if number > 0 && number <= displayCount
					{
						if let track = results[number-1] as? iTunesTrack
						{
							track.playOnce!(true)
							print("Enjoy the music!")
							return
						}
					}
					else
					{
						print("Invalid user input \"\(number)\". Exiting.")
						return
					}
				}
			}

			*/

			return processedResults
		}
		else
		{
			return []
		}
	}
	
	fileprivate func runAlbumSearch(_ arguments: [String])
	{
		if arguments.count < 3
		{
			print("No search arguments provided!\n")
			return
		}
		
		let searchString = arguments.suffix(from: 2).joined(separator: " ")
		
		if searchString.characters.count == 0
		{
			print("No search arguments provided!\n")
			return
		}
		
		if let libraryPlaylist = getLibraryPlaylist()
		{
			print("Searching albums for \"\(searchString)\"...")
			
			let results = libraryPlaylist.searchFor!(searchString, only: .all)
			var albums: [(human: String, query: String)] = []
			
			for result in results
			{
				if let track = result as? iTunesTrack,
					   let albumDesc = track.prettyAlbumDescription,
					   let albumQuery = track.searchableAlbumDescription, !albums.contains(
					where: { entry in
						return albumQuery == entry.query
					})
				{
					albums.append((albumDesc, albumQuery))
				}
			}
			
			let maxCount = 9
			let displayCount = min(albums.count, maxCount)
			
			if albums.count == 0
			{
				print("Got no results for your search. Please try a different search argument.\n")
				return
			}
			else
			{
				let word = albums.count > displayCount ? "top" : "all"
				print("Listing \(displayCount != 1 ? word+" " : "")\(displayCount) result\(displayCount != 1 ? "s" : ""):")
			}
			
			for i in 0 ..< displayCount
			{
				let listItem = "[\(i+1)]".bold
				print("\t\(listItem): \(albums[i].human)")
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
			   let libraryPlaylist = playlist as? iTunesLibraryPlaylist
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
		                                              andProperties: ["name": "tune"])
		{
			let playlists = (librarySource?.playlists!() as SBElementArray!) as NSMutableArray
			playlists.add(object)
			
			return object as iTunesPlaylist
		}
		
		return nil
	}
}

extension iTunesHandler: MediaPlayer
{
	/// Internal identification of this media player, such as "itunes"
	var playerId: String
	{
		return "itunes"
	}

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
}

func pprint(_ string: String)
{
	print(string.replacingOccurrences(of: "\t", with: "        "))
}

struct iTunesPlaybackInfo
{
	let progress: Double
	let status: iTunesEPlS
}

struct iTunesTrackSearchResult: SearchResultItem
{
	private let track: iTunesTrack

	fileprivate init(track: iTunesTrack)
	{
		self.track = track
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

	var time: String
	{
		return track.duration?.durationString ?? "--:--"
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

extension iTunesPlaylist
{
	func positionOfTrack(_ desiredTrack: iTunesTrack) -> Int?
	{
		for index in 0..<tracks!().count
		{
			if let track = tracks!()[index] as? iTunesTrack, track.id!() == desiredTrack.id!()
			{
				return index
			}
		}
		
		return nil
	}
}
