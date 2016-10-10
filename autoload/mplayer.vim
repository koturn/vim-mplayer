" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Mplayer frontend of Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


if has('win32unix')
  let g:mplayer#use_win_mplayer_in_cygwin = get(g:, 'mplayer#use_win_mplayer_in_cygwin', 0)
  let g:mplayer#cygwin_mount_dir = get(g:, 'mplayer#cygwin_mount_dir', '/cygdrive')
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
let g:mplayer#_use_job = get(g:, 'mplayer#_use_job', has('job'))
let g:mplayer#_use_timer = get(g:, 'mplayer#_use_timer', has('timers'))

let g:mplayer#enable_ctrlp_multi_select = get(g:, 'mplayer#enable_ctrlp_multi_select', 1)

let s:V = vital#of('mplayer')
let s:List = s:V.import('Data.List')
let s:P = s:V.import('Process')
let s:PM = s:V.import('ProcessManager')

let s:PROCESS_NAME = 'mplayer' | lockvar s:PROCESS_NAME
let s:WAIT_TIME = g:mplayer#_use_job ? 50 : 0.05 | lockvar s:WAIT_TIME
let s:EXIT_KEYCODE = char2nr('q') | lockvar s:EXIT_KEYCODE
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
lockvar s:INDO_COMMANDS
let s:KEY_ACTION_DICT = {
      \ "\<Left>": 'seek -10',
      \ "\<Right>": 'seek 10',
      \ "\<Up>": 'seek 60',
      \ "\<Down>": 'seek -60'
      \}
lockvar s:KEY_ACTION_DICT

call mplayer#complete#_import_local_vars(s:, 'keep')


let s:MPlayer = {
      \ 'mplayer': 'mplayer',
      \ 'option': 'option',
      \ 'rt_sw': 0
      \}
let s:instance_id = 0
let s:mplayer_list = []


if g:mplayer#_use_job
  function! mplayer#new() abort
    let mplayer = deepcopy(s:MPlayer)
    let mplayer.mplayer = g:mplayer#mplayer
    let mplayer.option = g:mplayer#option
    let mplayer.id = s:instance_id
    let s:instance_id += 1
    call add(s:mplayer_list, mplayer)

    let group = 'MPlayer' . mplayer.id
    execute 'augroup' group
    execute '  autocmd!'
    execute '  autocmd' group 'VimLeave * call s:mplayer_list[' . mplayer.id . '].stop()'
    execute 'augroup END'
    return mplayer
  endfunction

  function! s:MPlayer.start(custom_option) abort
    if !executable(self.mplayer)
      echoerr 'Error: Please install mplayer.'
      return
    endif
    call self.stop()
    let self.handle = job_start(self.mplayer . ' ' . self.option . ' '. a:custom_option, {
          \ 'out_mode': 'raw',
          \})
    call self._read()
  endfunction

  function! s:MPlayer.enqueue(...) abort
    if !self.is_playing()
      let self.handle = job_start(self.mplayer . ' ' . self.option . ' '. a:custom_option, {
            \ 'out_mode': 'raw'
            \})
    endif
    for cmd in s:make_loadcmds(s:List.flatten(a:000))
      call ch_sendraw(self.handle, s:DUMMY_COMMAND . "\n")
      call ch_sendraw(self.handle, cmd . "\n")
    endfor
    call self._read(s:WAIT_TIME)
  endfunction

  function! s:MPlayer.stop() abort
    if !has_key(self, 'handle') || !self.is_playing() | return | endif
    " call self.stop_rt_info()
    call job_stop(self.handle)
  endfunction

  function! s:MPlayer.is_playing() abort
    return job_status(self.handle) ==# 'run'
  endfunction

  function! s:MPlayer._command(cmd) abort
    if !self.is_playing() | return | endif
    call ch_sendraw(self.handle, s:DUMMY_COMMAND . "\n")
    call ch_sendraw(self.handle, a:cmd . "\n")
    return self._read()
  endfunction

  function! s:MPlayer._read(...) abort
    let wait_time = get(a:, 1, 50)
    let pattern = get(a:, 2, [])
    let raw_text = ch_readraw(self.handle, {'timeout': wait_time})
    return substitute(raw_text, s:DUMMY_PATTERN, '', 'g')
  endfunction

  function! s:MPlayer.flush() abort
    if !self.is_playing() | return | endif
    let r = [ch_readraw(self.handle), ch_readraw(self.handle, {'part': 'err'})]
    if r[0] !=# ''
      echo '[stdout]'
      echo r[0]
    endif
    if r[1] !=# ''
      echo '[stderr]'
      echo r[1]
    endif
  endfunction

  function! s:MPlayer.show_file_info() abort
    if !self.is_playing() | return | endif
    call ch_sendraw(self.handle, s:DUMMY_COMMAND . "\n")
    for cmd in s:INFO_COMMANDS
      call ch_sendraw(self.handle, cmd . "\n")
    endfor
    let text = substitute(iconv(self._read(), s:TENC, &enc), "'", '', 'g')
    let answers = map(split(text, s:LINE_BREAK), 'matchstr(v:val, "^ANS_.\\+=\\zs.*$")')
    if len(answers) == 0 | return | endif
    echo '[STANDARD INFORMATION]'
    try
      echo '  posiotion: ' s:to_timestr(answers[1]) '/' s:to_timestr(answers[0]) ' (' . answers[2] . '%)'
      echo '  filename:  ' answers[3]
      echo '[META DATA]'
      echo '  title:     ' answers[4]
      echo '  artist:    ' answers[5]
      echo '  album:     ' answers[6]
      echo '  year:      ' answers[7]
      echo '  comment:   ' answers[8]
      echo '  track:     ' answers[9]
      echo '  genre:     ' answers[10]
      echo '[AUDIO]'
      echo '  codec:     ' answers[11]
      echo '  bitrate:   ' answers[12]
      echo '  sample:    ' answers[13]
      if answers[14] !=# '' && answers[15] !=# '' && answers[16] !=# ''
        echo '[VIDEO]'
        echo '  codec:     ' answers[14]
        echo '  bitrate:   ' answers[15]
        echo '  resolution:' answers[16]
      endif
    catch /^Vim\%((\a\+)\)\=:E684: /
      echon ' '
      echohl ErrorMsg
      echon '... Failed to get file information'
      echohl None
    endtry
  endfunction

  function! s:MPlayer.show_timeinfo() abort
    call ch_sendraw(self.handle, s:DUMMY_COMMAND . "\n")
    call ch_sendraw(self.handle, "get_time_pos\n")
    call ch_sendraw(self.handle, "get_time_length\n")
    call ch_sendraw(self.handle, "get_percent_pos\n")
    let text = substitute(self._read(), "'", '', 'g')
    let answers = map(split(text, s:LINE_BREAK), 'matchstr(v:val, "^ANS_.\\+=\\zs.*$")')
    if len(answers) == 3
      echo '[MPlayer] position:' s:to_timestr(answers[1]) '/' s:to_timestr(answers[0]) ' (' . answers[2] . '%)'
    endif
  endfunction
else
  function! mplayer#new() abort
    let mplayer = deepcopy(s:MPlayer)
    let mplayer.mplayer = g:mplayer#mplayer
    let mplayer.option = g:mplayer#option
    let mplayer.handle = 'mplayer-' . s:instance_id
    let mplayer.id = s:instance_id
    let s:instance_id += 1
    call add(s:mplayer_list, mplayer)

    let group = 'MPlayer' . mplayer.id
    execute 'augroup' group
    execute '  autocmd!'
    execute '  autocmd' group 'VimLeave * call s:mplayer_list[' . mplayer.id . '].stop()'
    execute 'augroup END'
    return mplayer
  endfunction

  function! s:MPlayer.start(custom_option) abort
    if !executable(self.mplayer)
      echoerr 'Error: Please install mplayer.'
      return
    endif
    if !s:PM.is_available()
      echoerr 'Error: vimproc is unavailable.'
      return
    endif
    call self.stop()
    call s:PM.touch(
          \ self.handle, self.mplayer . ' '
          \ . self.option . ' '
          \ . a:custom_option
          \)
    call self._read()
  endfunction

  function! s:MPlayer.enqueue(...) abort
    if !self.is_playing()
      call s:PM.touch(self.handle, self.mplayer . ' ' . self.option)
      call self._read()
    endif
    for cmd in s:make_loadcmds(s:List.flatten(a:000))
      call s:PM.writeln(self.handle, s:DUMMY_COMMAND)
      call s:PM.writeln(self.handle, cmd)
    endfor
    call self._read(s:WAIT_TIME)
  endfunction

  function! s:MPlayer.stop() abort
    if !self.is_playing() | return | endif
    call self.stop_rt_info()
    call s:PM.kill(self.handle)
  endfunction

  function! s:MPlayer.is_playing() abort
    let status = 'dead'
    try
      let status = s:PM.status(self.handle)
    catch
    endtry
    return status ==# 'inactive' || status ==# 'active'
  endfunction

  function! s:MPlayer._command(cmd) abort
    if !self.is_playing() | return | endif
    call s:PM.writeln(self.handle, s:DUMMY_COMMAND)
    call s:PM.writeln(self.handle, a:cmd)
    return self._read()
  endfunction

  function! s:MPlayer._read(...) abort
    let wait_time = get(a:, 1, 0.05)
    let pattern = get(a:, 2, [])
    let raw_text = s:PM.read_wait(self.handle, wait_time, [])[0]
    return substitute(raw_text, s:DUMMY_PATTERN, '', 'g')
  endfunction

  function! s:MPlayer.flush() abort
    if !self.is_playing() | return | endif
    let r = s:PM.read(self.handle, [])
    if r[0] !=# ''
      echo '[stdout]'
      echo r[0]
    endif
    if r[1] !=# ''
      echo '[stderr]'
      echo r[1]
    endif
  endfunction
endif


function! s:MPlayer.play(...) abort
  let pos = match(a:000, '^--$')
  if pos == -1
    let pos = len(a:000)
  endif
  let custom_option = join(a:000[pos + 1 :], ' ')
  call self.start(custom_option)
  let filelist = a:000[: pos - 1]
  call self.enqueue(filelist)
endfunction

function! s:MPlayer.next(...) abort
  let n = get(a:, 1, 1)
  echo iconv(self._command('pt_step ' . n), s:TENC, &enc)
  call self._read()
endfunction

function! s:MPlayer.prev(...) abort
  let n = -get(a:, 1, 1)
  echo iconv(self._command('pt_step ' . n), s:TENC, &enc)
  call self._read()
endfunction

function! s:MPlayer.command(cmd, ...) abort
  if !self._is_playing() | return | endif
  let is_iconv = get(a:, 1, 0)
  let str = self._command(a:cmd)
  if is_iconv
    let str = iconv(str, s:TENC, &enc)
  endif
  echo matchstr(substitute(str, "^\e[A\r\e[K", '', ''), '^ANS_.\+=\zs.*$')
endfunction

function! s:MPlayer.set_seek(pos) abort
  let second = s:to_second(a:pos)
  let lastchar = a:pos[-1 :]
  if second != -1
    echo self._command('seek ' . second . ' 2')
  elseif lastchar ==# 's' || lastchar =~# '\d'
    echo self._command('seek ' . a:pos . ' 2')
  elseif lastchar ==# '%'
    echo self._command('seek ' . a:pos . ' 1')
  endif
endfunction

function! s:MPlayer.set_speed(speed, is_scaletempo) abort
  if a:is_scaletempo
    echo self._command('af_add scaletempo')
  else
    echo self._command('af_del scaletempo')
  endif
  echo self._command('speed_set ' . a:speed)
endfunction

function! s:MPlayer.set_equalizer(band_str) abort
  if has_key(s:eq_presets, a:band_str)
    call self._command('af_eq_set_bands ' . s:eq_presets[a:band_str])
  else
    call self._command('af_eq_set_bands ' . a:band_str)
  endif
endfunction

function! s:MPlayer.help(...) abort
  let arg = get(a:, 1, 'cmdlist')
  if has_key(s:HELP_DICT, arg)
    echo s:P.system(g:mplayer#mplayer . ' ' . s:HELP_DICT[arg])
  endif
endfunction


function! s:MPlayer.toggle_rt_timeinfo() abort
  if self.rt_sw
    call self.stop_rt_info()
  else
    call self.start_rt_info()
  endif
  let self.rt_sw = !self.rt_sw
endfunction

if g:mplayer#_use_timer
  let s:timer_dict = {}

  function! s:MPlayer.start_rt_info() abort
    if !self.is_playing() | return | endif
    let self.timer_id = timer_start(&updatetime, function('s:timer_update'), {'repeat': -1})
    let s:timer_dict[self.timer_id] = self
  endfunction

  function! s:MPlayer.stop_rt_info() abort
    call timer_stop(self.timer_id)
  endfunction

  function! s:timer_update(timer_id) abort
    call s:timer_dict[a:timer_id].show_timeinfo()
  endfunction
else
  function! s:MPlayer.start_rt_info() abort
    if !self.is_playing() | return | endif
    execute 'autocmd! MPlayer' . self.id 'CursorHold,CursorHoldI * call s:mplayer_list[' . self.id . '].update()'
  endfunction

  function! s:MPlayer.stop_rt_info() abort
    execute 'autocmd! MPlayer' . self.id 'CursorHold,CursorHoldI'
  endfunction

  function! s:MPlayer.update() abort
    call self.show_timeinfo()
    call feedkeys(mode() ==# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
  endfunction
endif

function! s:make_loadcmds(args) abort
  let loadcmds = []
  for arg in a:args
    for item in split(expand(arg, 1), "\n")
      if isdirectory(item)
        let glob_pattern = empty(g:mplayer#suffixes) ? '*' : ('*.{' . join(g:mplayer#suffixes, ',') . '}')
        let dir_items = split(globpath(item, glob_pattern, 1), "\n")
        call extend(loadcmds, map(filter(dir_items, 'filereadable(v:val)'), 's:process_file(v:val)'))
      elseif item =~# '^\%(cdda\|cddb\|dvd\|file\|ftp\|gopher\|tv\|vcd\|http\|https\)://'
        call add(loadcmds, 'loadfile ' . item . ' 1')
      else
        call add(loadcmds, s:process_file(expand(item, 1)))
      endif
    endfor
  endfor
  return has('win32unix') && g:mplayer#use_win_mplayer_in_cygwin
        \ ? map(loadcmds, 'substitute(v:val, g:mplayer#cygwin_mount_dir . "/\\(\\a\\)", "\\1:", "")')
        \ : loadcmds
endfunction

function! s:process_file(file) abort
  return (a:file =~# '\.\%(m3u\|m3u8\|pls\|wax\|wpl\|xspf\)$' ? 'loadlist ' : 'loadfile ') . string(a:file) . ' 1'
endfunction

function! s:to_timestr(secstr) abort
  let second = str2nr(a:secstr)
  let dec_part = str2float(a:secstr) - second
  let hour = second / 3600
  let second = second % 3600
  let minute = second / 60
  let second = second % 60
  return printf('%02d:%02d:%02d.%1d', hour, minute, second, float2nr(dec_part * 10))
endfunction

function! s:to_second(timestr) abort
  if a:timestr =~# '^\d\+:\d\+:\d\+\%(\.\d\+\)\?$'
    let parts = split(a:timestr, ':')
    return str2nr(parts[0]) * 3600 + str2nr(parts[1]) * 60 + str2nr(parts[2])
  elseif a:timestr =~# '^\d\+:\d\+\%(\.\d\+\)\?$'
    let parts = split(a:timestr, ':')
    return str2nr(parts[0]) * 60 + str2nr(parts[1])
  else
    return -1
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
