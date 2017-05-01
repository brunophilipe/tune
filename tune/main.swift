//
//  main.swift
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

class Main
{
	private let userInterface = UserInterface()
	private let iTunes = iTunesController()
	private var windowControllers: [UIWindowController]? = nil

	func run()
	{
		setlocale(LC_ALL, "en_US.UTF-8")

		guard userInterface.setup(rootState: buildStatesChain()) else
		{
			print("Failed to initialize screen")
			exit(-1)
		}

		self.windowControllers = buildWindowControllers()

		userInterface.preDrawHook =
		{
			let iTunes = self.iTunes
			let ui = self.userInterface

			if let windowControllers = self.windowControllers
			{
				for controller in windowControllers
				{
					if var desiree = controller as? DesiresTrackInfo
					{
						desiree.track			= iTunes.currentTrack
					}

					if var desiree = controller as? DesiresPlaybackInfo
					{
						desiree.playbackInfo	= iTunes.currentPlaybackInfo
					}

					if var desiree = controller as? DesiresCurrentPlaylist
					{
						desiree.currentPlaylist = iTunes.currentPlaylist
					}

					if var desiree = controller as? DesiresCurrentState
					{
						desiree.currentState	= ui.currentState
					}

				}
			}
		}

		userInterface.startEventLoop()
		userInterface.finalize()
	}

	private func buildStatesChain() -> UIState
	{
		let iTunes = self.iTunes

		let searchState = UIState(label: "search")
		searchState.identifier = UIState.TuneStates.search
		searchState.setSubState(UIState.parentState, forKeyCode: KEY_ESCAPE)
		searchState.setSubState(UIControlState(label: "tracks") { iTunes.playpause() }, forKeyCode: KEY_T_LOWER)
		searchState.setSubState(UIControlState(label: "albums") { iTunes.playpause() }, forKeyCode: KEY_A_LOWER)
		searchState.setSubState(UIControlState(label: "playlists") { iTunes.playpause() }, forKeyCode: KEY_P_LOWER)

		let rootState = UIState(label: "Root")
		rootState.identifier = UIState.TuneStates.root
		rootState.setSubState(UIState.quitState, forKeyCode: KEY_Q_LOWER)
		rootState.setSubState(UIControlState(label: "pause") { iTunes.playpause() },	forKeyCode: KEY_SPACE)
		rootState.setSubState(UIControlState(label: "stop") { iTunes.stop() },			forKeyCode: KEY_PERIOD)
		rootState.setSubState(searchState,												forKeyCode: KEY_S_LOWER)
		rootState.setSubState(UIControlState(label: "prev") { iTunes.previousTrack() }, forKeyCode: KEY_LEFT)
		rootState.setSubState(UIControlState(label: "next") { iTunes.nextTrack() },		forKeyCode: KEY_RIGHT)

		return rootState
	}

	private func buildWindowControllers() -> [UIWindowController]
	{
		let controllers: [UIWindowController] = [
			LogoWindowController(userInterface: userInterface),
			NowPlayingWindowController(userInterface: userInterface),
			PlayQueueWindowController(userInterface: userInterface),
			MediaBrowserWindowController(userInterface: userInterface),
			CommandsBarWindowController(userInterface: userInterface)
		]

		for controller in controllers
		{
			userInterface.registerWindow(controller.window)
		}

		return controllers
	}
}

protocol DesiresTrackInfo
{
	var track: iTunesTrack? { get set }
}

protocol DesiresPlaybackInfo
{
	var playbackInfo: iTunesPlaybackInfo? { get set }
}

protocol DesiresCurrentPlaylist
{
	var currentPlaylist: iTunesPlaylist? { get set }
}

protocol DesiresCurrentState
{
	var currentState: UIState? { get set }
}

extension UIState
{
	struct TuneStates
	{
		static let root = 1
		static let search = 2
	}
}

let main = Main()
main.run()
