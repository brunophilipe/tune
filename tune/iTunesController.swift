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

typealias Verb = (names: [String], brief: String, description: [String])

class iTunesController
{
	private var iTunesApp: iTunesApplication?
	
	private let verbs: [Verb] = [
		(
			["play"],
			"Start playing music.",
			["If paused, will resume playing. If stopped, will play the last", "played song."]
		), (
			["pause"],
			"Pause playback.",
			["If playing, will pause playback. If stopped, does nothing."]
		), (
			["next", "n"],
			"Go to the next track.",
			["Goes to the next track in the \"Up Next\" list or in the Apple", "Music stream."]
		), (
			["prev", "p", "previous"],
			"Go to the previous track.",
			["Goes to the previously played track (if possible)."]
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
		print("Where <verb> is:")
		
		for verb in verbs
		{
			let names = verb.names.joinWithSeparator(", ")
			
			print("\t\(names.bold): \(verb.brief)")
			
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
			
		case "next", "n":
			iTunesApp?.nextTrack!()
			
		case "prev", "p", "previous":
			iTunesApp?.previousTrack!()
			
		default:
			print("Bad argument provided: \(arguments[1])\n")
			return false
		}
		
		return true
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