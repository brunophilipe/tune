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
			return substring(to: truncationIndex) + "…"
		}
	}

	static func *(lhs: String, rhn: Int) -> String
	{
		return String.init(repeating: lhs, count: rhn)
	}

	static func *(lhs: String, rhn: Int32) -> String
	{
		return String.init(repeating: lhs, count: Int(rhn))
	}
}
