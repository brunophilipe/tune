//
//  Stack.swift
//  tune
//
//  Created by Bruno Philipe on 3/5/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
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

/// Simple wrapper around an array that only exposes a traditional Stack interface. You can `push()`, `pop()`, and query the `count` of
/// elements.
///
/// Ideally this class should be refactored to conform with some Swift collection protocol, but what is here works good enough.
class Stack<T>
{
	private var storage = [T]()

	/// Pushes an element into the top of the stack.
	func push(_ element: T)
	{
		storage.append(element)
	}

	/// Pops the top element of the stack and returns it. Returns `nil` is the stack is empty.
	func pop() -> T?
	{
		if storage.count > 0
		{
			return storage.remove(at: storage.endIndex - 1)
		}
		else
		{
			return nil
		}
	}

	/// Returns the amount of elements in the stack.
	var count: Int
	{
		return storage.count
	}
}
