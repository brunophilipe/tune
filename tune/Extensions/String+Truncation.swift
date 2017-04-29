//
//  String+Truncation.swift
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
}
