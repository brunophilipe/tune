//
//  ArgumentsParser.swift
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


typealias Verb = (names: [String], brief: String, description: [String], extra: String?)

let kUnknownArtist = "Unknown Artist".italic
let kUnknownTrack = "Unknown Track".italic
let kUnknownAlbum = "Unknown Album".italic

class iTunesController
{
	private let userInterface = UserInterface()

	fileprivate var iTunesApp: iTunesApplication?
	
	fileprivate let verbs: [Verb] = [
		(
			["info", "i"],
			"Information on the current track.",
			["If playing, will display info on the current track."],
			nil
		),(
			["play"],
			"Start playing music.",
			["If paused, will resume playing. If stopped, will play the last", "played song."],
			nil
		), (
			["pause"],
			"Pause playback.",
			["If playing, will pause playback. If stopped, does nothing."],
			nil
		), (
			["stop"],
			"Stop playback.",
			["If playing, will stop playback. If stopped, does nothing."],
			nil
		), (
			["next", "n"],
			"Go to the next track.",
			["Goes to the next track in the \"Up Next\" list or in the Apple", "Music stream."],
			nil
		), (
			["prev", "p", "previous"],
			"Go to the previous track.",
			["Goes to the previously played track (if possible)."],
			nil
		), (
			["search", "s"],
			"Search for tracks.",
			[
				"Searches for tracks by name.",
				"Requires search string argument."
			],
			"search string"
		), (
			["album", "a"],
			"Search for albums.",
			[
				"Searches for albums by name.",
				"Requires search string argument."
			],
			"search string"
		)
	]
	
	init()
	{
		iTunesApp = SBApplication(bundleIdentifier: "com.apple.iTunes")

		userInterface.setup()
	}
	
	func parseArguments(_ arguments: [String])
	{
		if !runParser(arguments)
		{
			printUsage()
		}
	}
	
	fileprivate func printUsage()
	{
		userInterface.showWelcome()
		userInterface.finalize()
//		printLogo()
//		print("Quick iTunes control from the command line.".underline)
//		print("\n")
//		
//		print("Usage:".bold)
//		print("\ttune <verb> [extra arguments]\n")
//		print("Where <verb> is one of: (\("underlined".underline) text denotes extra argument(s))\n")
//		
//		for verb in verbs
//		{
//			var names = verb.names.map({arg in return arg.bold}).joined(separator: ", ")
//			let hasExtra = verb.extra != nil
//			
//			if hasExtra
//			{
//				names = "(\(names))"
//			}
//			
//			print("\t\(names)\(hasExtra ? " \(verb.extra!.underline)" : ""): \(verb.brief)")
//			
//			for descLine in verb.description
//			{
//				print("\t\t\(descLine)")
//			}
//			
//			print("")
//		}
//		
//		print("\t")
	}
	
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
	
	fileprivate func runTrackSearch(_ arguments: [String])
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
			print("Searching for \"\(searchString)\"...")
			
			let results = libraryPlaylist.searchFor!(searchString, only: .all)
			let maxCount = 9
			let displayCount = min(results.count, maxCount)
			
			if results.count == 0
			{
				print("Got no results for your search. Please try a different search argument.\n")
				return
			}
			else
			{
				let word = results.count > displayCount ? "top" : "all"
				print("Listing \(displayCount != 1 ? word+" " : "")\(displayCount) result\(displayCount != 1 ? "s" : ""):")
			}
			
			for i in 0 ..< displayCount
			{
				var desc: String
				
				if let track = results[i] as? iTunesTrack
				{
					var artist = track.artist
					var title = track.name
					var album = track.album
					
					if artist == nil || artist == ""
					{
						artist = kUnknownArtist
					}
					
					if title == nil || title == ""
					{
						title = kUnknownTrack
					}
					
					if album == nil || album == ""
					{
						album = kUnknownAlbum
					}
					
					desc = "\(artist!) - \"\(title!)\" (\(album!))"
				}
				else
				{
					desc = "Unknwon track (could not parse...)"
				}
				
				let listItem = "[\(i+1)]".bold
				
				print("\t\(listItem): \(desc)")
			}
			
			print("\nInsert [1-\(displayCount)] to pick song to play, 'a' to play all in a queue, or 0 to cancel: ")
			
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
			
			print("Invalid user input.. Exiting.")
			return
		}
		else
		{
			print("Could not get iTunes library!\n")
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
			
			print("Invalid user input.. Exiting.")
			return
		}
		else
		{
			print("Could not get iTunes library!\n")
		}
	}
	
	fileprivate func printCurrentTrackInfo()
	{
		printLogo()
		if let track = iTunesApp?.currentTrack, track.size > 0
		{
			print("Current track information:")
			printTrackInfo(track)
		}
		else
		{
			print("No track currently being played.")
			print("Use \("tune s <string>".underline) to lookup songs.")
		}
	}
	
	fileprivate func printTrackInfo(_ track: iTunesTrack)
	{
		var artist = track.artist
		var title = track.name
		var album = track.album
		
		if artist == nil || artist?.characters.count == 0
		{
			artist = kUnknownArtist
		}
		
		if title == nil || title?.characters.count == 0
		{
			title = kUnknownTrack
		}
		
		if album == nil || album?.characters.count == 0
		{
			album = kUnknownAlbum
		}
		
		let duration = track.duration ?? 0.0
		let durMin = Int(duration/60)
		let durSec = Int(duration.truncatingRemainder(dividingBy: 60))
		let durString = "\(durMin < 10 ? "0\(durMin)" : "\(durMin)"):" + "\(durSec < 10 ? "0\(durSec)" : "\(durSec)")"
		
		var year = track.year
		
		if year == 0
		{
			year = nil
		}
		
		print("\t   \("title".bold): \(title!)")
		print("\t  \("artist".bold): \(artist!)")
		print("\t   \("album".bold): \(album!) \(year != nil ? "(\(year!))" :"")")
		print("\t\("duration".bold): \(durString)")
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
		if let object = Tools.instantiateObject(from: iTunesApp as! SBApplication, typeName: "playlist", andProperties: ["name": "tune"])
		{
			let playlists = (librarySource?.playlists!() as SBElementArray!) as NSMutableArray
			playlists.add(object)
			
			return object as iTunesPlaylist
		}
		
		return nil
	}
	
	fileprivate func getUserInput() -> String?
	{
		let stdin = FileHandle.standardInput
		var capture = String(data: stdin.availableData, encoding: .utf8)
		capture = capture?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		return capture
	}
	
	fileprivate func printLogo()
	{
		print("  dP                              ".red)
		print("  88                              ".lightRed)
		print("d8888P dP    dP 88d888b. .d8888b. ".yellow)
		print("  88   88    88 88'  `88 88ooood8 ".green)
		print("  88   88.  .88 88    88 88.  ... ".lightBlue)
		print("  dP   `88888P' dP    dP `88888P' ".blue)
		print("\n")
	}
}

func pprint(_ string: String)
{
	print(string.replacingOccurrences(of: "\t", with: "        "))
}

extension iTunesTrack
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
