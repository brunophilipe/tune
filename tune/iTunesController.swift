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

typealias Verb = (names: [String], brief: String, description: [String], extra: String?)

class iTunesController
{
	private var iTunesApp: iTunesApplication?
	
	private let verbs: [Verb] = [
		(
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
		)
	]
	
	init()
	{
		iTunesApp = SBApplication(bundleIdentifier: "com.apple.iTunes") as? iTunesApplication
	}
	
	func parseArguments(arguments: [String])
	{
		if !runParser(arguments)
		{
			printUsage()
		}
	}
	
	private func printUsage()
	{
		printLogo()
		
		print("Usage:".bold)
		print("\ttune <verb> [extra arguments]\n")
		print("Where <verb> is (\("underlined".underline) text denotes extra argument(s)):\n")
		
		for verb in verbs
		{
			var names = verb.names.map({arg in return arg.bold}).joinWithSeparator(", ")
			let hasExtra = verb.extra != nil
			
			if hasExtra
			{
				names = "(\(names))"
			}
			
			print("\t\(names)\(hasExtra ? " \(verb.extra!.underline)" : ""): \(verb.brief)")
			
			for descLine in verb.description
			{
				print("\t\t\(descLine)")
			}
			
			print("")
		}
		
		print("\t")
	}
	
	private func runParser(arguments: [String]) -> Bool
	{
		if arguments.count < 2
		{
			print("No arguments provided!\n")
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
			runSearch(arguments)
			
		default:
			print("Bad argument provided: \(arguments[1])\n")
			return false
		}
		
		return true
	}
	
	private func runSearch(arguments: [String])
	{
		if arguments.count < 3
		{
			print("No search arguments provided!\n")
			return
		}
		
		let searchString = arguments.suffixFrom(2).joinWithSeparator(" ")
		
		if searchString.characters.count == 0
		{
			print("No search arguments provided!\n")
			return
		}
		
		if let libraryPlaylist = getLibraryPlaylist()
		{
			print("Searching for \"\(searchString)\"...")
			
			let results = libraryPlaylist.searchFor!(searchString, only: .All)
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
				let desc: String!
				
				if let track = results[i] as? iTunesTrack
				{
					let artist = track.artist ?? "Unknown Artist"
					let title = track.name ?? "Unknown Track"
					let album = track.album ?? "Unknown Album"
					
					desc = "\(artist) - \"\(title)\" (\(album))"
				}
				else
				{
					desc = "Unknwon track (could not parse...)"
				}
				
				let listItem = "[\(i+1)]".bold
				
				print("\t\(listItem): \(desc)")
			}
			
			print("\nInsert value [1-\(displayCount)] to pick song to play or 0 to cancel: ")
			
			if let input = getUserInput(), number = Int(input)
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
			
			print("Invalid user input.. Exiting.")
			return
		}
		else
		{
			print("Could not get iTunes library!\n")
		}
	}
	
	private func getLibraryPlaylist() -> iTunesLibraryPlaylist?
	{
		var librarySource: iTunesSource? = nil
		
		for sourceElement in iTunesApp?.sources!() as SBElementArray!
		{
			if let source = sourceElement as? iTunesSource where source.kind == .Library
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
			if let playlist = playlistElement as? iTunesPlaylist where playlist.specialKind == .Library,
			   let libraryPlaylist = playlist as? iTunesLibraryPlaylist
			{
				return libraryPlaylist
			}
		}
		
		return nil
	}
	
	private func getUserInput() -> String?
	{
		let stdin = NSFileHandle.fileHandleWithStandardInput()
		var capture = NSString(data: stdin.availableData, encoding: NSUTF8StringEncoding) as? String ?? nil
		capture = capture?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		return capture
	}
	
	private func printLogo()
	{
		print("  dP                              ".red)
		print("  88                              ".lightRed)
		print("d8888P dP    dP 88d888b. .d8888b. ".yellow)
		print("  88   88    88 88'  `88 88ooood8 ".green)
		print("  88   88.  .88 88    88 88.  ... ".lightBlue)
		print("  dP   `88888P' dP    dP `88888P' ".blue)
		print("\n")
		print("Quick iTunes control from the command line.".underline)
		print("\n")
	}
}

func pprint(string: String)
{
	print(string.stringByReplacingOccurrencesOfString("\t", withString: "        "))
}