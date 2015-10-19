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
endif

let g:mplayer#mplayer = get(g:, 'mplayer#mplayer', 'mplayer')
if has('win32') || has('win32unix') && g:mplayer#use_win_mplayer_in_cygwin
  let g:mplayer#option = get(g:, 'mplayer#option',
        \ '-idle -quiet -slave -af equalizer=0:0:0:0:0:0:0:0:0:0 -vo direct3d')
else
  let g:mplayer#option = get(g:, 'mplayer#option',
        \ '-idle -quiet -slave -af equalizer=0:0:0:0:0:0:0:0:0:0')
endif


let s:V = vital#of('mplayer')
let s:P = s:V.import('Process')
let s:PM = s:V.import('ProcessManager')

let s:rt_sw = 0
let s:PROCESS_NAME = 'mplayer' | lockvar s:PROCESS_NAME
let s:WAIT_TIME = 0.05 | lockvar s:WAIT_TIME
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
let s:DUMMY_PATTERN = '.*ANS_ERROR=PROPERTY_UNKNOWN' . s:LINE_BREAK
let s:INFO_COMMANDS = [
      \ 'get_time_pos', 'get_time_length', 'get_percent_pos', 'get_file_name',
      \ 'get_meta_title', 'get_meta_artist', 'get_meta_album', 'get_meta_year',
      \ 'get_meta_comment', 'get_meta_track', 'get_meta_genre',
      \ 'get_audio_codec', 'get_audio_bitrate', 'get_audio_samples',
      \ 'get_video_codec', 'get_video_bitrate', 'get_video_resolution'
      \]
let s:KEY_ACTION_DICT = {
      \ "\<Left>": 'seek -10',
      \ "\<Right>": 'seek 10',
      \ "\<Up>": 'seek 60',
      \ "\<Down>": 'seek -60'
      \}
lockvar s:DUMMY_COMMAND
lockvar s:DUMMY_PATTERN
lockvar s:INDO_COMMANDS

let s:eq_presets = {
      \ 'acoustic': '0:1:2:0:0:0:0:0:2:2',
      \ 'bass': '3:2:1:0:-1:-2:-3:-4:-5:-6',
      \ 'blues': '-1:0:2:1:0:0:0:0:-1:-3',
      \ 'boost': '-1:1:3:2:1:1:2:3:1:-1',
      \ 'classic': '-3:3:3:0:-3:-3:-3:-3:-1:-1',
      \ 'country': '-1:0:0:2:2:0:0:0:3:3',
      \ 'dance': '-3:2:3:-1:-3:-3:-2:-2:2:2',
      \ 'eargasm': '-5:-2:1:-1:-2:-3:-1:-4:3:0',
      \ 'folk': '-1:0:1:0:2:0:0:0:2:0',
      \ 'grunge': '-4:0:0:-2:0:0:2:3:0:-3',
      \ 'jazz': '-1:-1:-1:2:2:2:-1:1:3:3',
      \ 'koturn': '0:1:3:2:1:0:1:2:1:0',
      \ 'metal': '-4:0:0:0:0:0:3:0:3:1',
      \ 'new_age': '0:3:3:0:0:0:0:0:1:1',
      \ 'normal': '2:2:2:2:2:2:2:2:2:2',
      \ 'normalZero': '0:0:0:0:0:0:0:0:0:0',
      \ 'oldies': '-2:0:2:1:0:0:0:0:-2:-5',
      \ 'opera': '-2:-2:-2:1:2:0:3:0:-2:-2',
      \ 'perfect': '-5:-2:1:-1:-2:-3:-1:1:3:0',
      \ 'rap': '-4:-3:-1:-1:-4:-4:-3:-3:1:3',
      \ 'reggae': '-2:-1:-1:-4:-1:2:3:-1:2:3',
      \ 'rock': '-2:0:1:2:-2:-2:-1:-1:3:3',
      \ 'speech': '-2:0:2:1:0:0:0:0:-2:-5',
      \ 'swing': '-2:-1:-1:-1:2:2:-1:1:3:3',
      \ 'techno': '-8:-1:2:-3:-3:-4:-2:-2:3:3',
      \}
let s:SUB_ARG_DICT = {}
let s:SUB_ARG_DICT.dvdnav = sort([
      \ 'up', 'down', 'left', 'right',
      \ 'menu', 'select', 'prev', 'mouse'
      \])
let s:SUB_ARG_DICT.menu = sort(['up', 'down', 'ok', 'cancel', 'hide'])
let s:SUB_ARG_DICT.step_property = sort([
      \ 'osdlevel',
      \ 'speed', 'loop',
      \ 'chapter',
      \ 'angle',
      \ 'percent_pos', 'time_pos',
      \ 'volume', 'balance', 'mute',
      \ 'audio_delay',
      \ 'switch_audio', 'switch_angle', 'switch_title',
      \ 'capturing', 'fullscreen', 'deinterlace',
      \ 'ontop', 'rootwin',
      \ 'border', 'framedropping',
      \ 'gamma', 'brightness', 'contrast', 'saturation',
      \ 'hue', 'panscan', 'vsync',
      \ 'switch_video', 'switch_program',
      \ 'sub', 'sub_source', 'sub_file', 'sub_vob', 'sub_demux', 'sub_delay',
      \ 'sub_pos', 'sub_alignment', 'sub_visibility',
      \ 'sub_forced_only', 'sub_scale',
      \ 'tv_brightness', 'tv_contrast', 'tv_saturation', 'tv_hue',
      \ 'teletext_page', 'teletext_subpage', 'teletext_mode',
      \ 'teletext_format', 'teletext_half_page'
      \])
let s:SUB_ARG_DICT.set_property = sort(s:SUB_ARG_DICT.step_property + ['stream_pos'])
let s:SUB_ARG_DICT.get_property = sort(s:SUB_ARG_DICT.set_property + [
      \ 'pause',
      \ 'filename', 'path',
      \ 'demuxer',
      \ 'stream_start', 'stream_end', 'stream_length', 'stream_time_pos',
      \ 'chapters', 'length',
      \ 'metadata', 'metadata/album', 'metadata/artist', 'metadata/comment',
      \ 'metadata/genre', 'metadata/title', 'metadata/track','metadata/year',
      \ 'audio_format', 'audio_codec', 'audio_bitrate',
      \ 'samplerate', 'channels',
      \ 'video_format', 'video_codec', 'video_bitrate',
      \ 'width', 'height', 'fps', 'aspect'
      \])
lockvar s:SUB_ARG_DICT

let s:HELP_DICT = {
      \ 'cmdlist': '-input cmdlist',
      \ 'af': '-af help',
      \ 'ao': '-ao help',
      \ 'vf': '-vf help',
      \ 'vo': '-vo help'
      \}
lockvar s:HELP_DICT


function! mplayer#play(...) abort
  if !executable(g:mplayer#mplayer)
    echoerr 'Error: Please install mplayer.'
    return
  endif
  if !s:PM.is_available()
    echoerr 'Error: vimproc is unavailable.'
    return
  endif
  call mplayer#stop()
  let pos = match(a:000, '^--$')
  if pos == -1
    let pos = len(pos)
  endif
  let filelist = a:000[: pos - 1]
  let custom_option = join(a:000[pos + 1 :], ' ')
  call s:PM.touch(
        \ s:PROCESS_NAME, g:mplayer#mplayer . ' '
        \ . g:mplayer#option . ' '
        \ . custom_option
        \)
  call s:read()
  call s:enqueue(s:make_loadcmds(filelist))
endfunction

function! mplayer#enqueue(...) abort
  if !mplayer#is_playing()
    call s:PM.touch(s:PROCESS_NAME, g:mplayer#mplayer . ' ' . g:mplayer#option)
    call s:read()
  endif
  call s:enqueue(s:make_loadcmds(a:000))
endfunction

function! mplayer#stop() abort
  if !mplayer#is_playing() | return | endif
  call s:stop_rt_info()
  call s:PM.kill(s:PROCESS_NAME)
endfunction

function! mplayer#is_playing() abort
  let status = 'dead'
  try
    let status = s:PM.status(s:PROCESS_NAME)
  catch
  endtry
  return status ==# 'inactive' || status ==# 'active'
endfunction

function! mplayer#next(...) abort
  let n = get(a:, 1, 1)
  echo iconv(s:command('pt_step ' . n), s:TENC, &enc)
  call s:read()
endfunction

function! mplayer#prev(...) abort
  let n = -get(a:, 1, 1)
  echo iconv(s:command('pt_step ' . n), s:TENC, &enc)
  call s:read()
endfunction

function! mplayer#command(cmd, ...) abort
  if !mplayer#is_playing() | return | endif
  let is_iconv = get(a:, 1, 0)
  let str = s:command(a:cmd)
  if is_iconv
    let str = iconv(str, s:TENC, &enc)
  endif
  echo substitute(substitute(str, "^\e[A\r\e[K", '', ''), '^ANS_.\+=\(.*\)$', '\1', '')
endfunction

function! mplayer#set_seek(pos) abort
  let second = s:to_second(a:pos)
  let lastchar = a:pos[len(a:pos) - 1]
  if second != -1
    echo s:command('seek ' . second . ' 2')
  elseif lastchar ==# 's' || lastchar =~# '\d'
    echo s:command('seek ' . a:pos . ' 2')
  elseif lastchar ==# '%'
    echo s:command('seek ' . a:pos . ' 1')
  endif
endfunction

function! mplayer#set_speed(speed, is_scaletempo) abort
  if a:is_scaletempo
    echo s:command('af_add scaletempo')
  else
    echo s:command('af_del scaletempo')
  endif
  echo s:command('speed_set ' . a:speed)
endfunction

function! mplayer#set_equalizer(band_str) abort
  if has_key(s:eq_presets, a:band_str)
    call s:command('af_eq_set_bands ' . s:eq_presets[a:band_str])
  else
    call s:command('af_eq_set_bands ' . a:band_str)
  endif
endfunction

function! mplayer#operate_with_key() abort
  if !mplayer#is_playing() | return | endif
  let key = getchar()
  while key != s:EXIT_KEYCODE
    if type(key) == 0
      call s:PM.writeln(s:PROCESS_NAME, 'key_down_event ' . key)
    elseif has_key(s:KEY_ACTION_DICT, key)
      call s:PM.writeln(s:PROCESS_NAME, s:KEY_ACTION_DICT[key])
    endif
    let key = getchar()
  endwhile
  call s:PM.writeln(s:PROCESS_NAME, s:DUMMY_COMMAND)
  call s:read(s:WAIT_TIME)
endfunction

function! mplayer#show_file_info() abort
  if !mplayer#is_playing() | return | endif
  call s:PM.writeln(s:PROCESS_NAME, s:DUMMY_COMMAND)
  for cmd in s:INFO_COMMANDS
    call s:PM.writeln(s:PROCESS_NAME, cmd)
  endfor
  let text = substitute(iconv(s:read(), s:TENC, &enc), "'", '', 'g')
  let answers = map(split(text, s:LINE_BREAK), 'substitute(v:val, "^ANS_.\\+=\\(.*\\)$", "\\1", "")')
  if len(answers) == 0 | return | endif
  echo '[STANDARD INFORMATION]'
  try
    echo '  posiotion: ' s:to_timestr(answers[0]) '/' s:to_timestr(answers[1]) ' (' . answers[2] . '%)'
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

function! mplayer#help(...) abort
  let arg = get(a:, 1, 'cmdlist')
  if has_key(s:HELP_DICT, arg)
    echo s:P.system(g:mplayer#mplayer . ' ' . s:HELP_DICT[arg])
  endif
endfunction

function! mplayer#toggle_rt_timeinfo() abort
  if s:rt_sw
    call s:stop_rt_info()
  else
    call s:start_rt_info()
  endif
  let s:rt_sw = !s:rt_sw
endfunction

function! s:start_rt_info() abort
  if !mplayer#is_playing() | return | endif
  autocmd! MPlayer CursorHold,CursorHoldI * call s:update()
endfunction

function! s:stop_rt_info() abort
  autocmd! MPlayer CursorHold,CursorHoldI
endfunction

function! mplayer#flush() abort
  if !mplayer#is_playing() | return | endif
  let r = s:PM.read(s:PROCESS_NAME, [])
  if r[0] != ''
    echo '[stdout]'
    echo r[0]
  endif
  if r[1] != ''
    echo '[stderr]'
    echo r[1]
  endif
endfunction

function! mplayer#cmd_complete(arglead, cmdline, cursorpos) abort
  if !exists('s:cmd_complete_cache')
    let cmdlist = s:P.system(g:mplayer#mplayer . ' -input cmdlist')
    let s:cmd_complete_cache = sort(map(split(cmdlist, "\n"), 'split(v:val, " \\+")[0]'))
  endif
  let args = split(split(a:cmdline, '\s*\\\@<!|\s*')[-1], '\s\+')
  let nargs = len(args)
  let candidates = []
  if has_key(s:SUB_ARG_DICT, args[-1])
    let candidates = s:SUB_ARG_DICT[args[-1]]
  elseif nargs == 3 && a:arglead !=# '' && has_key(s:SUB_ARG_DICT, args[-2])
    let candidates = s:SUB_ARG_DICT[args[-2]]
  elseif nargs == 1 || (nargs == 2 && a:arglead !=# '')
    let candidates = s:cmd_complete_cache
  endif
  return s:match_filter(copy(candidates), a:arglead)
endfunction

function! mplayer#step_property_complete(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(copy(s:SUB_ARG_DICT.step_property), a:arglead, a:cmdline)
endfunction

function! mplayer#get_property_complete(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(copy(s:SUB_ARG_DICT.get_property), a:arglead, a:cmdline)
endfunction

function! mplayer#set_property_complete(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(copy(s:SUB_ARG_DICT.set_property), a:arglead, a:cmdline)
endfunction

function! mplayer#equlizer_complete(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(sort(keys(s:eq_presets)), a:arglead, a:cmdline)
endfunction

function! mplayer#help_complete(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(sort(keys(s:HELP_DICT)), a:arglead, a:cmdline)
endfunction


function! s:enqueue(loadcmds) abort
  for cmd in a:loadcmds
    call s:writeln(cmd)
  endfor
  call s:read(s:WAIT_TIME)
endfunction

function! s:command(cmd) abort
  if !mplayer#is_playing() | return | endif
  call s:writeln(a:cmd)
  return s:read()
endfunction

function! s:writeln(cmd) abort
  call s:PM.writeln(s:PROCESS_NAME, s:DUMMY_COMMAND)
  call s:PM.writeln(s:PROCESS_NAME, a:cmd)
endfunction

function! s:read(...) abort
  let wait_time = get(a:, 1, 0.05)
  let pattern = get(a:, 2, [])
  let raw_text = s:PM.read_wait(s:PROCESS_NAME, wait_time, [])[0]
  return substitute(raw_text, s:DUMMY_PATTERN, '', 'g')
endfunction

function! s:make_loadcmds(args) abort
  let loadcmds = []
  for arg in a:args
    for item in split(expand(arg), "\n")
      if isdirectory(item)
        let dir_items = split(globpath(item, '*'), "\n")
        let loadcmds += map(filter(dir_items, 'filereadable(v:val)'), 's:process_file(v:val)')
      elseif item =~# '^\(cdda\|cddb\|dvd\|file\|ftp\|gopher\|tv\|vcd\|http\|https\)://'
        call add(loadcmds, 'loadfile ' . item . ' 1')
      else
        call add(loadcmds, s:process_file(expand(item)))
      endif
    endfor
  endfor
  if has('win32unix') && g:mplayer#use_win_mplayer_in_cygwin
    return map(loadcmds, 'substitute(v:val, "/cygdrive/\\(\\a\\)", "\\1:", "")')
  else
    return loadcmds
  endif
endfunction

function! s:process_file(file) abort
  return (a:file =~# '\.\(m3u\|m3u8\|pls\|wax\|wpl\|xspf\)$' ? 'loadlist ' : 'loadfile ') . string(a:file) . ' 1'
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
  if a:timestr =~# '^\d\+:\d\+:\d\+\(\.\d\+\)\?$'
    let parts = split(a:timestr, ':')
    return str2nr(parts[0]) * 3600 + str2nr(parts[1]) * 60 + str2nr(parts[2])
  elseif a:timestr =~# '^\d\+:\d\+\(\.\d\+\)\?$'
    let parts = split(a:timestr, ':')
    return str2nr(parts[0]) * 60 + str2nr(parts[1])
  else
    return -1
  endif
endfunction

function! s:update() abort
  call s:show_timeinfo()
  call feedkeys(mode() ==# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
endfunction

function! s:show_timeinfo() abort
  call s:PM.writeln(s:PROCESS_NAME, s:DUMMY_COMMAND)
  call s:PM.writeln(s:PROCESS_NAME, 'get_time_pos')
  call s:PM.writeln(s:PROCESS_NAME, 'get_time_length')
  call s:PM.writeln(s:PROCESS_NAME, 'get_percent_pos')
  let text = substitute(s:read(), "'", '', 'g')
  let answers = map(split(text, s:LINE_BREAK), 'substitute(v:val, "^ANS_.\\+=\\(.*\\)$", "\\1", "")')
  if len(answers) == 3
    echo '[MPlayer] position:' s:to_timestr(answers[0]) '/' s:to_timestr(answers[1]) ' (' . answers[2] . '%)'
  endif
endfunction

function! s:first_arg_complete(candidates, arglead, cmdline) abort
  let nargs = len(split(split(a:cmdline, '\s*\\\@<!|\s*')[-1], '\s\+'))
  if nargs == 1 || (nargs == 2 && a:arglead !=# '')
    return s:match_filter(a:candidates, a:arglead)
  endif
endfunction

function! s:match_filter(candidates, arglead) abort
  return filter(a:candidates, 'stridx(tolower(v:val), tolower(a:arglead)) == 0')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
