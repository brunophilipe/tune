//
//  String+Additions.swift
//  tune
//
//  Created by Bruno Philipe on 29/4/17.
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

extension String
{
	func truncated(to maxLength: Int) -> String
	{
		if maxLength >= characters.count
		{
			return self
		}
		else
		{
			let truncationIndex = index(startIndex, offsetBy: maxLength - 1)
			return (substring(to: truncationIndex).trimmingCharacters(in: .whitespaces) + "…").padded(to: maxLength)
		}
	}
	
	func padded(to length: Int, alignLeft: Bool = true) -> String
	{
		if width > Int32(length)
		{
			return truncated(to: length)
		}
		else if alignLeft
		{
			return "\(self)\(" " * (Int32(length) - width))"
		}
		else
		{
			return "\(" " * (Int32(length) - width))\(self)"
		}
	}

	static func *(lhs: String, rhn: Int) -> String
	{
		return String.init(repeating: lhs, count: rhn)
	}

	static func *(lhs: String, rhn: Int32) -> String
	{
		return String.init(repeating: lhs, count: Int(max(rhn, 0)))
	}

	/// Width of the string in a monospaced font
	var width: Int32
	{
		return Int32(characters.count)
	}

	var fullRange: Range<Index>
	{
		return startIndex..<endIndex
	}
}
