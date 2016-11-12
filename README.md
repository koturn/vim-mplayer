vim-mplayer
===========

[![Powered by vital.vim](https://img.shields.io/badge/powered%20by-vital.vim-80273f.svg)](https://github.com/vim-jp/vital.vim)

[Mplayer](http://www.mplayerhq.hu/design7/news.html) frontend of Vim. You can
enjoy music/video on Vim!!


## Usage

Play music by following command.

```vim
:MPlayer [File or Directory] ...
```

If you specify directory, this plugin play back the music which mplayer can
play back.
Playlist file is detected by the extension of the file name.

The following table is the command list of this plugin.

Command                                              | Description
-----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------
`MPlayer <file or directory> ...`                    | Play back specified files.
`MPlayerEnqueue <file or directory> ...`             | Add the files to the current playlist.
`MPlayerCommand <arg> ...`                           | Send slave mode commands to the mplayer.
`MPlayerEqualizer <preset name or band string>`      | Set the equalizer of the mplayer.
`MPlayerGetProperty <property>`                      | Print out the current value of a property.
`MPlayerLoop <the number of loop>`                   | Specify the number of loop. 0 means infinite loop, -1 means no loop.
`MPlayerNext`                                        | Move to the next music/movie of the current playlist.
`MPlayerOperateWithKey`                              | Operate the mplayer with keyboard inputs.
`MPlayerPrev`                                        | Move to the previous music/movie of the current playlist.
`MPlayerSeek <position>`                             | Seek to the specified position. Argument format is `.*%` (percent based position) or `.*s` (seconds based position)
`MPlayerSeekToEnd`                                   | Seek to the end of file.
`MPlayerSeekToHead`                                  | Seek to the head of file.
`MPlayerSetProperty <property> <values> ...`         | Set a value to the specified property.
`MPlayerShowCommandList`                             | Show slave mode commands.
`MPlayerShowFileInfo`                                | Show the file information of the song which currently playing.
`MPlayerSpeed <value>`                               | Set the play speed of the mplayer. When bang is added, don't keep pitch.
`MPlayerStepProperty <property> <value> <direction>` | Change a property by value, or increase by a default if value is not given or zero.
`MPlayerStop`                                        | Stop the mplayer (kill process of the mplayer)
`MPlayerToggleMute`                                  | Toggle mute or not.
`MPlayerTogglePause`                                 | Toggle pause-state or not.
`MPlayerToggleRTTimeInfo`                            | Toggle successively show or not show playback time.
`MPlayerVolume <value>`                              | Set the volume of the mplayer.


## Installation

### With [dein.vim](https://github.com/Shougo/neobundle.vim)

Write following code to your `.vimrc` and execute `:call dein#install()` in
your Vim.

```vim
" Dependent plugins
" for Vim without +job feature (neovim doesn't need vimproc)
call dein#add('Shougo/vimproc.vim')
" Optional plugins
call dein#add('Shougo/unite.vim')
call dein#add('Shougo/denite.nvim')
call dein#add('ctrlpvim/ctrlp.vim')
call dein#add('junegunn/fzf')
call dein#add('LeafCage/alti.vim')
call dein#add('kamichidu/vim-milqi')

call dein#add('koturn/vim-mplayer', {
      \ 'depends': [
      \   'vimproc.vim',
      \   'unite.vim',
      \   'denite.vim',
      \   'ctrlp.vim',
      \   'alti.vim',
      \   'vim-milqi'
      \ ],
      \ 'on_cmd': [
      \   'AltiMPlayer',
      \   'CtrlPMPlayer',
      \   'MilqiMPlayer',
      \   'FZFMPlayer',
      \   'MPlayer',
      \   'MPlayerEnqueue',
      \   'MPlayerCommand',
      \   'MPlayerStop',
      \   'MPlayerVolume',
      \   'MPlayerVolumeBar',
      \   'MPlayerSpeed',
      \   'MPlayerEqualizer',
      \   'MPlayerToggleMute',
      \   'MPlayerTogglePause',
      \   'MPlayerToggleRTTimeInfo',
      \   'MPlayerLoop',
      \   'MPlayerSeek',
      \   'MPlayerSeekToHead',
      \   'MPlayerSeekToEnd',
      \   'MPlayerOperateWithKey',
      \   'MPlayerPrev',
      \   'MPlayerNext',
      \   'MPlayerShowFileInfo',
      \   'MPlayerCommand',
      \   'MPlayerGetProperty',
      \   'MPlayerSetProperty',
      \   'MPlayerStepProperty',
      \   'MPlayerHelp',
      \   'MPlayerFlush'
      \ ],
      \ 'on_source': ['unite.vim', 'denite.nvim'],
      \})
```

### With [NeoBundle](https://github.com/Shougo/neobundle.vim)

Write following code to your `.vimrc` and execute `:NeoBundleInstall` in your
Vim.

```vim
NeoBundle 'koturn/vim-mplayer'
```

If you want to use `:NeoBundleLazy`, write following code in your .vimrc.

```vim
NeoBundle 'koturn/vim-mplayer', {
      \ 'depends': [
      \   'Shougo/vimproc.vim',
      \   'Shougo/unite.vim',
      \   'Shougo/denite.vim',
      \   'ctrlpvim/ctrlp.vim',
      \   'LeafCage/alti.vim',
      \   'kamichidu/vim-milqi'
      \ ],
      \ 'on_cmd': [
      \   'AltiMPlayer',
      \   'CtrlPMPlayer',
      \   'MilqiMPlayer',
      \   'FZFMPlayer',
      \   'MPlayer',
      \   'MPlayerEnqueue',
      \   'MPlayerCommand',
      \   'MPlayerStop',
      \   'MPlayerVolume',
      \   'MPlayerVolumeBar',
      \   'MPlayerSpeed',
      \   'MPlayerEqualizer',
      \   'MPlayerToggleMute',
      \   'MPlayerTogglePause',
      \   'MPlayerToggleRTTimeInfo',
      \   'MPlayerLoop',
      \   'MPlayerSeek',
      \   'MPlayerSeekToHead',
      \   'MPlayerSeekToEnd',
      \   'MPlayerOperateWithKey',
      \   'MPlayerPrev',
      \   'MPlayerNext',
      \   'MPlayerShowFileInfo',
      \   'MPlayerCommand',
      \   'MPlayerGetProperty',
      \   'MPlayerSetProperty',
      \   'MPlayerStepProperty',
      \   'MPlayerHelp',
      \   'MPlayerFlush'
      \ ],
      \ 'on_source': ['unite.vim', 'denite.nvim'],
      \}
```

### With [Vundle](https://github.com/VundleVim/Vundle.vim)

Write following code to your `.vimrc` and execute `:PluginInstall` in your Vim.

```vim
" Dependent plugins
" for Vim without +job feature (neovim doesn't need vimproc)
Plugin 'Shougo/vimproc.vim'
" Optional plugins
Plugin 'Shougo/unite.vim'
Plugin 'Shougo/denite.nvim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'junegunn/fzf'
Plugin 'LeafCage/alti.vim'
Plugin 'kamichidu/vim-milqi'

Plugin 'koturn/vim-mplayer'
```

### With [vim-plug](https://github.com/junegunn/vim-plug)

Write following code to your `.vimrc` and execute `:PlugInstall` in your Vim.

```vim
" Dependent plugins
" for Vim without +job feature (neovim doesn't need vimproc)
Plug 'Shougo/vimproc.vim'
" Optional plugins
Plug 'Shougo/unite.vim'
Plug 'Shougo/denite.nvim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/fzf'
Plug 'LeafCage/alti.vim'
Plug 'kamichidu/vim-milqi'

Plug 'koturn/vim-mplayer'
```

### With [vim-pathogen](https://github.com/tpope/vim-pathogen)

Clone this repository to the package directory of pathogen.

```
$ git clone https://github.com/koturn/vim-mplayer.git ~/.vim/bundle/vim-mplayer
```

### With packages feature

In the first, clone this repository to the package directory.

```
$ git clone https://github.com/koturn/vim-mplayer.git ~/.vim/pack/koturn/opt/vim-mplayer
```

Second, add following code to your `.vimrc`.

```vim
packadd vim-mplayer
```

### With manual

If you don't want to use plugin manager, put files and directories on
`~/.vim/`, or `%HOME%/vimfiles/` on Windows.


## Dependent plugins

### Required

If you use vim without `+job` feature or your don't use [neovim](https://github.com/neovim/neovim), following plugin is neccessary.

- [vimproc.vim](https://github.com/Shougo/vimproc.vim)

### Optional

This plugin provies extensions for following plugins.

- [Shougo/unite.vim](https://github.com/Shougo/unite.vim)
- [Shougo/denite.nvim](https://github.com/Shougo/denite.nvim)
- [ctrlpvim/ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim)
- [junegunn/fzf](https://github.com/junegunn/fzf)
- [LeafCage/alti.vim](https://github.com/LeafCage/alti.vim)
- [kamichidu/vim-milqi](https://github.com/kamichidu/vim-milqi)


## Requirements

- [mplayer](http://www.mplayerhq.hu/design7/news.html)


## LICENSE

This software is released under the MIT License, see [LICENSE](LICENSE).
