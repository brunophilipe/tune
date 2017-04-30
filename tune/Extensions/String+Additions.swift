//
//  String+Additions.swift
//  tune
//
//  Created by Bruno Philipe on 29/4/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
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
}
