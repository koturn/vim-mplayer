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

Command                                             | Description
----------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------
```MPlayer [File or Directory] ...```               | Play back specified files.
```MPlayerEnqueue [File or Directory] ...```        | Add the files to the current playlist.
```MPlayerEqualizer [Preset name or Band string]``` | Set the equalizer of the mplayer.
```MPlayerLoop [The number of loop]```              | Specify the number of loop. 0 means infinite loop, -1 means no loop.
```MPlayerNext```                                   | Move to the next music/movie of the current playlist.
```MPlayerOperateWithKey```                         | Operate the mplayer with keyboard inputs.
```MPlayerNext```                                   | Move to the previous music/movie of the current playlist.
```MPlayerSeek [Position]```                        | Seek to the specified position. Argument format is ```.*%``` (percent based position) or ```.*s``` (seconds based position)
```MPlayerSeekToEnd```                              | Seek to the end of file.
```MPlayerSeekToHead```                             | Seek to the head of file.
```MPlayerSendCommand [arg] ...```                  | Send slave mode commands to the mplayer.
```MPlayerShowCommandList```                        | Show slave mode commands.
```MPlayerShowFileInfo```                           | Show the file information of the song which currently playing.
```MPlayerSpeed [value]```                          | Set the play speed of the mplayer.
```MPlayerStop```                                   | Stop the mplayer (kill process of the mplayer)
```MPlayerToggleMute```                             | Toggle mute or not.
```MPlayerTogglePause```                            | Toggle pause-state or not.
```MPlayerVolume [value]```                         | Set the volume of the mplayer.


## Dependent plugins

- [vimproc.vim](https://github.com/Shougo/vimproc.vim)


## Requirements

- mplayer


## LICENSE

This software is released under the MIT License, see LICENSE.
