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

		let windowControllers = buildWindowControllers(userInterface)

		for controller in windowControllers
		{
			userInterface.registerWindow(controller.window)
		}

		self.windowControllers = windowControllers

		userInterface.preDrawHook =
		{
			let iTunes = self.iTunes
//			let ui = self.userInterface

			if let windowControllers = self.windowControllers
			{
				for controller in windowControllers
				{
					switch controller
					{
					case let nowPlayingController as NowPlayingWindowController:
						nowPlayingController.track			= iTunes.currentTrack
						nowPlayingController.playbackInfo	= iTunes.currentPlaybackInfo

					default:
						break
					}
				}
			}

//			mainModule.currentState			= ui.currentState
//			mainModule.currentTrack			= iTunes.currentTrack
//			mainModule.currentPlaybackInfo	= iTunes.currentPlaybackInfo
//			mainModule.currentPlaylist		= iTunes.currentPlaylist
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

	private func buildWindowControllers(_ ui: UserInterface) -> [UIWindowController]
	{
		return [
			LogoWindowController(userInterface: ui),
			NowPlayingWindowController(userInterface: ui)
		]
	}
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
