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

struct Main
{
	static func run()
	{
		setlocale(LC_ALL, "en_US.UTF-8")

		let userInterface = UserInterface()
		let iTunes = iTunesController()

		func buildStatesChain() -> UIState
		{
			let rootState = UIState(label: "Root")

			rootState.setSubState(UIState.quitState, forKeyCode: KEY_Q_LOWER)

			return rootState
		}

		guard userInterface.setup(rootState: buildStatesChain()) else
		{
			print("Failed to initialize screen")
			exit(-1)
		}

		let mainModule = UIMainModule(userInterface: userInterface)

		userInterface.preDrawHook =
		{
			mainModule.currentTrack = iTunes.currentTrack
			mainModule.currentPlaybackInfo = iTunes.currentPlaybackInfo
			mainModule.currentState = userInterface.currentState
		}

		userInterface.mainUIModule = mainModule

		userInterface.startEventLoop()

		//let controller = iTunesController()
		//controller.parseArguments(CommandLine.arguments)
		
		userInterface.finalize()
	}
}

Main.run()
