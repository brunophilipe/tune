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

/// This class should be called 'ThingsThatDidntGoAnywhereElseYetAndLauncher', since that's what it is.
/// Ideally things should be split in different classes and be called in the most modular way possible,
/// and this is partially done with `buildWindowControllers()` for example, but it could be better.
/// I just haven't figured out an obvious good way of organizing things, mostly because the goals aren't clear.
class Main
{
	private let userInterface = UserInterface()
	private let iTunes = iTunesHandler()
	private let searchEngine = SearchEngine()

	private var windowControllers: [UIWindowController]? = nil

	func run()
	{
		setlocale(LC_ALL, "en_US.UTF-8")

		let (rootState, searchBrowseState) = buildStatesChain()

		guard userInterface.setup(rootState: rootState) else
		{
			print("Failed to initialize screen")
			exit(-1)
		}

		self.windowControllers = buildWindowControllers(searchBrowseState: searchBrowseState)

		searchEngine.mediaPlayer = iTunes

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

	private func buildStatesChain() -> (rootState: UIState, searchBrowseState: UIState)
	{
		let iTunes = self.iTunes

		let (searchState, searchBrowseState) = buildSearchState()

		let rootState = UIState(label: "Root", id: UIState.TuneStates.root)
		rootState.setSubState(UIState.quitState, forKeyCode: KEY_Q_LOWER)
		rootState.setSubState(UIControlState(label: "pause") { iTunes.playPause() },	forKeyCode: KEY_SPACE)
		rootState.setSubState(UIControlState(label: "stop") { iTunes.stop() },			forKeyCode: KEY_PERIOD)
		rootState.setSubState(searchState,												forKeyCode: KEY_S_LOWER)
		rootState.setSubState(UIControlState(label: "prev") { iTunes.previousTrack() }, forKeyCode: KEY_LEFT)
		rootState.setSubState(UIControlState(label: "next") { iTunes.nextTrack() },		forKeyCode: KEY_RIGHT)

		return (rootState, searchBrowseState)
	}

	private func buildSearchState() -> (searchState: UIState, searchBrowsingState: UIState)
	{
		let searchState = UIState(label: "search", id: UIState.TuneStates.search)
		searchState.setSubState(UIState.popStackState, forKeyCode: KEY_ESCAPE)

		// Search Tracks State

		let searchTracksState = UITextInputState(label: "tracks",
		                                         id: UIState.TuneStates.searchTracks,
		                                         textFeedBlock: self.searchEngine.search(forTracks:))

		searchState.setSubState(searchTracksState, forKeyCode: KEY_T_LOWER)

		// Search Albums State

		let searchAlbumsState = UITextInputState(label: "albums",
		                                         id: UIState.TuneStates.searchAlbums,
		                                         textFeedBlock: self.searchEngine.search(forAlbums:))

		searchState.setSubState(searchAlbumsState, forKeyCode: KEY_A_LOWER)

		// Search Playlists State

		let searchPlaylistsState = UITextInputState(label: "playlists",
		                                            id: UIState.TuneStates.searchPlaylists,
		                                            textFeedBlock: self.searchEngine.search(forPlaylists:))

		searchState.setSubState(searchPlaylistsState, forKeyCode: KEY_P_LOWER)

		// Search Results Browsing State

		let searchBrowseState = UIState(label: "browse results", id: UIState.TuneStates.searchBrowsing)
		searchBrowseState.setSubState(.popStackState, forKeyCode: KEY_ESCAPE)
		searchTracksState.setSubState(searchBrowseState, forKeyCode: KEY_RETURN)
		searchAlbumsState.setSubState(searchBrowseState, forKeyCode: KEY_RETURN)
		searchPlaylistsState.setSubState(searchBrowseState, forKeyCode: KEY_RETURN)

		return (searchState, searchBrowseState)
	}

	private func buildWindowControllers(searchBrowseState: UIState) -> [UIWindowController]
	{
		let searchWindowController = SearchWindowController(userInterface: userInterface)

		let controllers: [UIWindowController] = [
			LogoWindowController(userInterface: userInterface),
			NowPlayingWindowController(userInterface: userInterface),
			PlayQueueWindowController(userInterface: userInterface),
			MediaBrowserWindowController(userInterface: userInterface),
			CommandsBarWindowController(userInterface: userInterface),
			searchWindowController
		]

		searchEngine.delegate = searchWindowController
		searchBrowseState.delegate = searchWindowController

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
		static let searchTracks = 3
		static let searchAlbums = 4
		static let searchPlaylists = 5
		static let searchBrowsing = 6
	}
}

let main = Main()
main.run()
