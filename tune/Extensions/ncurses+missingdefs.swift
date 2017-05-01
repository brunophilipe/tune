//
//  ncurses+missingdefs.swift
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

func NCURSES_BITS(_ mask: Int32, _ shift: Int32) -> Int32
{
	return ((mask) << ((shift) + NCURSES_ATTR_SHIFT))
}

let A_STANDOUT			= NCURSES_BITS(1,8)
let A_UNDERLINE			= NCURSES_BITS(1,9)
let A_REVERSE			= NCURSES_BITS(1,10)
let A_BLINK				= NCURSES_BITS(1,11)
let A_DIM				= NCURSES_BITS(1,12)
let A_BOLD				= NCURSES_BITS(1,13)
let A_ALTCHARSET		= NCURSES_BITS(1,14)
let A_INVIS				= NCURSES_BITS(1,15)
let A_PROTECT			= NCURSES_BITS(1,16)
let A_HORIZONTAL		= NCURSES_BITS(1,17)
let A_LEFT				= NCURSES_BITS(1,18)
let A_LOW				= NCURSES_BITS(1,19)
let A_RIGHT				= NCURSES_BITS(1,20)
let A_TOP				= NCURSES_BITS(1,21)
let A_VERTICAL			= NCURSES_BITS(1,22)
