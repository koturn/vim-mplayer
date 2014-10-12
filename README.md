vim-mplayer
===========

[Mplayer](http://www.mplayerhq.hu/design7/news.html) frontend of Vim. You can
enjoy music on Vim!!


## Usage

Play music by following command.

```vim
:MPlayer [File or Directory] ...
```

If you specify directory, this plugin play back the music which mplayer can
play back.
Playlist file is detected by the extension of the file name.

The following table is the command list of this plugin.

Command                                                  | Description
---------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------
```MPlayer <file or directory> ...```                    | Play back specified files.
```MPlayerEnqueue <file or directory> ...```             | Add the files to the current playlist.
```MPlayerCommand <arg> ...```                           | Send slave mode commands to the mplayer.
```MPlayerEqualizer <preset name or band string>```      | Set the equalizer of the mplayer.
```MPlayerGetProperty <property>```                      | Print out the current value of a property.
```MPlayerLoop <the number of loop>```                   | Specify the number of loop. 0 means infinite loop, -1 means no loop.
```MPlayerNext```                                        | Move to the next music/movie of the current playlist.
```MPlayerOperateWithKey```                              | Operate the mplayer with keyboard inputs.
```MPlayerPrev```                                        | Move to the previous music/movie of the current playlist.
```MPlayerSeek <position>```                             | Seek to the specified position. Argument format is ```.*%``` (percent based position) or ```.*s``` (seconds based position)
```MPlayerSeekToEnd```                                   | Seek to the end of file.
```MPlayerSeekToHead```                                  | Seek to the head of file.
```MPlayerSetProperty <property> <values> ...```         | Set a value to the specified property.
```MPlayerShowCommandList```                             | Show slave mode commands.
```MPlayerShowFileInfo```                                | Show the file information of the song which currently playing.
```MPlayerSpeed <value>```                               | Set the play speed of the mplayer. When bang is added, don't keep pitch.
```MPlayerStepProperty <property> <value> <direction>``` | Change a property by value, or increase by a default if value is not given or zero.
```MPlayerStop```                                        | Stop the mplayer (kill process of the mplayer)
```MPlayerToggleMute```                                  | Toggle mute or not.
```MPlayerTogglePause```                                 | Toggle pause-state or not.
```MPlayerVolume <value>```                              | Set the volume of the mplayer.


## Dependent plugins

- [vimproc.vim](https://github.com/Shougo/vimproc.vim)


## Requirements

- mplayer


## LICENSE

This software is released under the MIT License, see [LICENSE](LICENSE).
