# tune

Control iTunes from the command line

---

![screenshot](http://i.imgur.com/cvQBFbI.png)

This is an experiment on `ncurses`, `ScriptingBridge`, and `Swift`.

The current version is a reimplementation of the old tune I wrote ages ago, which had a direct launch argument API. Now it uses `ncurses` for a pretty text-based UI.

You can see the evolution of tune through [some asciicasts I've recorded in asciinema](https://asciinema.org/~brunophilipe).

### Compiling

1. Clone or download this repo
2. Run `cd tune`
2. Run `make`
3. Run `./build/Release/tune`

You can run the following command to add tune to your run path without moving any file. And then when you compile a new version, the link will automatically point to the new binary:

```
ln -s $(pwd)/build/Release/tune /usr/local/bin/tune
```

### Compatibility

This software is only supported on macOS, since `ScriptingBridge` is not available outside of it.

### To-Do

* **Other media players**

It would be nice to make tune support other media players, such as Spotify. The application uses a generic protocol-based entities to pass 
info back-and-forth between the UI and the control layer, so adding some other players shouldn't be too complicated.

### License

```
Copyright © 2017 Bruno Philipe. All rights reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
