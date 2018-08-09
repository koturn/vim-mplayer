" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


" {{{ Global variables
if has('win32unix')
  let g:mplayer#use_win_mplayer_in_cygwin = get(g:, 'mplayer#use_win_mplayer_in_cygwin', 0)
endif

let g:mplayer#mplayer = get(g:, 'mplayer#mplayer', 'mplayer')
if has('win32') || has('win32unix') && g:mplayer#use_win_mplayer_in_cygwin
  let g:mplayer#option = get(g:, 'mplayer#option',
        \ '-nofontconfig -idle -quiet -slave -af equalizer=0:0:0:0:0:0:0:0:0:0 -vo direct3d')
else
  let g:mplayer#option = get(g:, 'mplayer#option',
        \ '-nofontconfig -idle -quiet -slave -af equalizer=0:0:0:0:0:0:0:0:0:0')
endif
let g:mplayer#suffixes = get(g:, 'mplayer#suffixes', ['*'])
let g:mplayer#engine = get(g:, 'mplayer#engine', has('job') || has('nvim') ? 'job' : 'vimproc')
let g:mplayer#_use_timer = get(g:, 'mplayer#_use_timer', has('timers'))
let g:mplayer#mru_size = get(g:, 'mplayer#mru_size', 100)
let g:mplayer#tiemr_cycle = 1000
let g:mplayer#enable_ctrlp_multi_select = get(g:, 'mplayer#enable_ctrlp_multi_select', 1)
" }}}

" {{{ import vital.vim library
let s:V = vital#mplayer#new()
let s:List = s:V.import('Data.List')
let s:CacheFile = s:V.import('System.Cache').new('file', {'cache_dir': expand('~/.cache/vim-mplayer')})
" }}}

" {{{ Constants
if has('win32unix') && g:mplayer#use_win_mplayer_in_cygwin
  let s:TENC = 'cp932'
else
  let s:TENC = &termencoding
endif
lockvar s:TENC
if has('win32') || has('win32unix') && g:mplayer#use_win_mplayer_in_cygwin
  let s:LINE_BREAK = "\r\n"
else
  let s:LINE_BREAK = "\n"
endif
lockvar s:LINE_BREAK

let s:MRU_ID_BASE = has('win32unix') ? 'mru_win32unix' : 'mru'

let s:DUMMY_COMMAND = 'get_property __NONE__'
lockvar s:DUMMY_COMMAND
let s:DUMMY_PATTERN = '.*ANS_ERROR=PROPERTY_UNKNOWN' . s:LINE_BREAK
lockvar s:DUMMY_PATTERN

let s:INFO_COMMANDS = [
      \ 'get_time_pos', 'get_time_length', 'get_percent_pos', 'get_file_name',
      \ 'get_meta_title', 'get_meta_artist', 'get_meta_album', 'get_meta_year',
      \ 'get_meta_comment', 'get_meta_track', 'get_meta_genre',
      \ 'get_audio_codec', 'get_audio_bitrate', 'get_audio_samples',
      \ 'get_video_codec', 'get_video_bitrate', 'get_video_resolution'
      \]
lockvar s:INFO_COMMANDS

let s:eq_presets = mplayer#complete#_import_local_var('eq_presets')
let s:SUB_ARG_DICT = mplayer#complete#_import_local_var('SUB_ARG_DICT')
let s:HELP_DICT = mplayer#complete#_import_local_var('HELP_DICT')
" }}}


let s:MPlayer = {
      \ 'mplayer': g:mplayer#mplayer,
      \ 'option': g:mplayer#option,
      \}
let s:instance_id = 0
let s:mplayer_list = []


function! mplayer#get_suffix_globptn() abort " {{{
  return empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
endfunction " }}}


function! mplayer#new(...) abort " {{{
  let engine = a:0 > 0 ? a:1 : g:mplayer#engine
  let mplayer = extend(copy(s:MPlayer), mplayer#engine#{engine}#define())
  let mplayer.id = s:instance_id
  let mplayer.mru_id = s:MRU_ID_BASE . s:instance_id
  let s:mru_list = s:CacheFile.get(mplayer.mru_id)
  let mplayer.mru_list = s:mru_list is# '' ? [] : s:mru_list
  let s:instance_id += 1
  call add(s:mplayer_list, mplayer)

  let group = 'MPlayer' . mplayer.id
  execute 'augroup' group
  execute '  autocmd!'
  execute '  autocmd' group 'VimLeave * call s:mplayer_list[' . mplayer.id . '].stop()'
  execute 'augroup END'
  return mplayer
endfunction " }}}

function! mplayer#_import_local_var(name) abort " {{{
  return s:[a:name]
endfunction " }}}


function! s:MPlayer.play(...) abort " {{{
  let pos = match(a:000, '^--$')
  if pos == -1
    let pos = a:0
  endif
  let custom_option = join(a:000[pos + 1 :], ' ')
  call self.start(custom_option)
  call self.enqueue(a:000[: pos - 1])
endfunction " }}}

function! s:MPlayer.enqueue(...) abort " {{{
  if !self.is_playing()
    call self.start('')
  endif
  let items = s:get_media_items(s:List.flatten(a:000))
  let self.mru_list = s:List.uniq(extend(self.mru_list, items, 0)[: (g:mplayer#mru_size - 1)])
  call self._write(join(extend(s:make_loadcmds(items), [s:DUMMY_COMMAND, '']), "\n"))
  call self._read()
endfunction " }}}

function! s:MPlayer.get_mru_list() abort " {{{
  return copy(self.mru_list)
endfunction " }}}

function! s:MPlayer.update_mru_listfile() abort " {{{
  call s:CacheFile.set(self.mru_id, filter(self.mru_list, 'filereadable(v:val) || v:val =~# "^\\%(cdda\\|cddb\\|dvd\\|file\\|ftp\\|gopher\\|tv\\|vcd\\|http\\|https\\)://"'))
endfunction " }}}

function! s:MPlayer.reload_mru_listfile() abort " {{{
  let s:mru_list = s:CacheFile.get(self.mru_id)
  let self.mru_list = s:mru_list is# '' ? [] : s:mru_list
endfunction " }}}

function! s:MPlayer.clear_mru_listfile() abort " {{{
  call s:CacheFile.set(self.mru_id, [])
  let self.mru_list = []
endfunction " }}}

function! s:MPlayer.stop() abort " {{{
  if !self.is_playing() | return | endif
  call self._write("quit\n")
  call self.update_mru_listfile()
endfunction " }}}

function! s:MPlayer.get_file_info() abort " {{{
  if !self.is_playing() | return | endif
  return s:get_file_info(substitute(iconv(self._command(join(s:INFO_COMMANDS, "\n")), s:TENC, &enc), "'", '', 'g'))
endfunction " }}}

function! s:MPlayer._command(cmd) abort " {{{
  if !self.is_playing() | return | endif
  call self._write(join([s:DUMMY_COMMAND, a:cmd, ''], "\n"))
  return substitute(self._read(), s:DUMMY_PATTERN, '', 'g')
endfunction " }}}

function! s:MPlayer.command(cmd, ...) abort " {{{
  let is_iconv = a:0 > 0 ? a:1 : 0
  let str = self._command(a:cmd)
  return matchstr(substitute(is_iconv ? iconv(str, s:TENC, &enc) : str, "^\e[A\r\e[K", '', ''), '^ANS_.\+=\zs.*$')
endfunction " }}}

function! s:MPlayer.next(...) abort " {{{
  let n = a:0 > 0 ? a:1 : 1
  return iconv(self._command('pt_step ' . n), s:TENC, &enc)
endfunction " }}}

function! s:MPlayer.prev(...) abort " {{{
  let n = -(a:0 > 0 ? a:1 : 1)
  return iconv(self._command('pt_step ' . n), s:TENC, &enc)
endfunction " }}}

function! s:MPlayer.set_loop(n) abort " {{{
  return self._command('loop ' . a:n . ' 1')
endfunction " }}}

function! s:MPlayer.set_volume(level) abort " {{{
  return self._command('volume ' . a:level . ' 1')
endfunction " }}}

function! s:MPlayer.set_seek(pos) abort " {{{
  let [second, lastchar] = [s:to_second(a:pos), a:pos[-1 :]]
  return second != -1 ? self._command('seek ' . second . ' 2')
        \ : lastchar ==# 's' || lastchar =~# '\d' ? self._command('seek ' . a:pos . ' 2')
        \ : lastchar ==# '%' ? self._command('seek ' . a:pos . ' 1')
        \ : ''
endfunction " }}}

function! s:MPlayer.set_seek_to_head() abort " {{{
  return self._command('seek 0 1')
endfunction " }}}

function! s:MPlayer.set_seek_to_end() abort " {{{
  return self._command('seek 100 1')
endfunction " }}}

function! s:MPlayer.set_speed(speed, is_scaletempo) abort " {{{
  return [
        \ a:is_scaletempo ? self._command('af_add scaletempo') : self._command('af_del scaletempo'),
        \ self._command('speed_set ' . a:speed)
        \]
endfunction " }}}

function! s:MPlayer.set_equalizer(band_str) abort " {{{
  return self._command('af_eq_set_bands ' . get(s:eq_presets, a:band_str, a:band_str))
endfunction " }}}

function! s:MPlayer.toggle_mute() abort " {{{
  return self._command('mute')
endfunction " }}}

function! s:MPlayer.toggle_pause() abort " {{{
  if !self.is_playing() | return | endif
  call self._write("pause\n")
  return substitute(self._read(), s:DUMMY_PATTERN, '', 'g')
endfunction " }}}


function! s:get_media_items(args) abort " {{{
  let [items, globptn] = [[], mplayer#get_suffix_globptn()]
  for arg in a:args
    for item in split(expand(arg, 1), "\n")
      if filereadable(item) || item =~# '^\%(cdda\|cddb\|dvd\|file\|ftp\|gopher\|tv\|vcd\|http\|https\)://'
        call add(items, fnamemodify(item, ':p'))
      elseif isdirectory(item)
        call extend(items, map(filter(split(globpath(item, globptn, 1), "\n"), 'filereadable(v:val)'), 'fnamemodify(v:val, ":p")'))
      endif
    endfor
  endfor
  return items
endfunction " }}}

function! s:make_loadcmds(items) abort " {{{
  if has('win32unix') && g:mplayer#use_win_mplayer_in_cygwin
    let cyg_subst_ptn = '^' . system('cygpath -u c:')[: -3] . '\(\a\)'
    return map(a:items, '(v:val =~# "\\.\\%(m3u\\|m3u8\\|pls\\|wax\\|wpl\\|xspf\\)$" ? "loadlist " : "loadfile \"") . substitute(v:val, cyg_subst_ptn, "\\1:", "") . "\" 1"')
  else
    return map(a:items, '(v:val =~# "\\.\\%(m3u\\|m3u8\\|pls\\|wax\\|wpl\\|xspf\\)$" ? "loadlist " : "loadfile \"") . v:val . "\" 1"')
  endif
endfunction " }}}

function! s:get_file_info(text) abort " {{{
  let answers = map(split(a:text, s:LINE_BREAK), 'matchstr(v:val, "^ANS_.\\+=\\zs.*$")')
  return len(answers) < 17 ? {} : {
        \ 'time_pos': answers[0],
        \ 'time_length': answers[1],
        \ 'percent_pos': answers[2],
        \ 'filename': answers[3],
        \ 'meta': {
        \   'title': answers[4],
        \   'artist': answers[5],
        \   'album': answers[6],
        \   'year': answers[7],
        \   'comment': answers[8],
        \   'track': answers[9],
        \   'genre': answers[10]
        \ },
        \ 'audio': {
        \   'codec': answers[11],
        \   'bitrate': answers[12],
        \   'sample': answers[13]
        \ },
        \ 'video': {
        \   'codec': answers[14],
        \   'bitrate': answers[15],
        \   'resolution': answers[16]
        \ }
        \}
endfunction " }}}

function! s:to_second(timestr) abort " {{{
  let parts = split(a:timestr, ':')
  return a:timestr =~# '^\d\+:\d\+:\d\+\%(\.\d\+\)\?$' ? (str2nr(parts[0]) * 3600 + str2nr(parts[1]) * 60 + str2nr(parts[2]))
        \ : a:timestr =~# '^\d\+:\d\+\%(\.\d\+\)\?$' ? (str2nr(parts[0]) * 60 + str2nr(parts[1]))
        \ : -1
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
