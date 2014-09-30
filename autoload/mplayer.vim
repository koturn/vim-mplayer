" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Mplayer frontend of Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let g:mplayer#command = get(g:, 'mplayer#command', 'mplayer')
if has('win32')
  let g:mplayer#option = get(g:, 'mplayer#option',
        \ '-idle -quiet -slave -af equalizer=0:0:0:0:0:0:0:0:0:0 -vo direct3d')
else
  let g:mplayer#option = get(g:, 'mplayer#option',
        \ '-idle -quiet -slave -af equalizer=0:0:0:0:0:0:0:0:0:0')
endif
let s:eq_presets = {
      \ 'normal': '0:0:0:0:0:0:0:0:0:0',
      \ 'bass': '2.25:2.0:1.75:1.50:1.25:1.00:0.75:0.5:0.25:0',
      \ 'classic': '0:3:3:1.5:0:0:0:0:1:1',
      \ 'perfect': '0.75:1.5:2.25:1.75:1.5:1.25:1.75:2.25:2.75:2'
      \}

let s:V = vital#of('mplayer')
let s:JSON = s:V.import('Web.JSON')
let s:PM = s:V.import('ProcessManager')

let s:PROCESS_NAME = 'mplayer' | lockvar s:PROCESS_NAME
let s:WAIT_TIME = 0.5 | lockvar s:WAIT_TIME
let s:NRQ = char2nr('q') | lockvar s:NRQ
let s:DUMMY_COMMAND = 'get_property __NONE__'
let s:DUMMY_PATTERN = '.*ANS_ERROR=PROPERTY_UNKNOWN' . (has('win32') ? "\r\n" : "\n")
let s:INFO_COMMANDS = [
      \ 'get_percent_pos',
      \ 'get_time_pos',
      \ 'get_time_length',
      \ 'get_file_name',
      \ 'get_video_codec',
      \ 'get_video_bitrate',
      \ 'get_video_resolution',
      \ 'get_audio_codec',
      \ 'get_audio_bitrate',
      \ 'get_audio_samples',
      \ 'get_meta_title',
      \ 'get_meta_artist',
      \ 'get_meta_album',
      \ 'get_meta_year',
      \ 'get_meta_comment',
      \ 'get_meta_track',
      \ 'get_meta_genre'
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


function! mplayer#play(...)
  if !executable(g:mplayer#command)
    echoerr 'Error: Please install mplayer to listen streaming radio.'
    return
  endif
  if !s:PM.is_available()
    echoerr 'Error: vimproc is unavailable.'
    return
  endif
  call mplayer#stop()
  call s:PM.touch(s:PROCESS_NAME, g:mplayer#command . ' ' . g:mplayer#option)
  call s:read()
  call s:enqueue(s:make_loadcmds(a:000))
endfunction

function! mplayer#enqueue(...)
  if !mplayer#is_playing()
    call s:PM.touch(s:PROCESS_NAME, g:mplayer#command . ' ' . g:mplayer#option)
    call s:read()
  endif
  call s:enqueue(s:make_loadcmds(a:000))
endfunction

function! mplayer#stop()
  if !mplayer#is_playing() | return | endif
  call s:PM.kill(s:PROCESS_NAME)
endfunction

function! mplayer#is_playing()
  let l:status = 'dead'
  try
    let l:status = s:PM.status(s:PROCESS_NAME)
  catch
  endtry
  return l:status ==# 'inactive' || l:status ==# 'active'
endfunction

function! mplayer#change(n)
  call mplayer#send_command('pt_step ' . a:n)
  call s:read()
endfunction

function! mplayer#send_command(cmd, ...)
  if !mplayer#is_playing() | return | endif
  let l:is_iconv = get(a:, 1, 0)
  call s:writeln(a:cmd)
  echo l:is_iconv ? iconv(s:read(), &tenc, &enc) : s:read()
endfunction

function! mplayer#set_loop(n)
  call mplayer#send_command('loop ' . a:n . ' 1')
endfunction

function! mplayer#seek_to_head()
  call mplayer#send_command('seek 0 1')
endfunction

function! mplayer#seek_to_end()
  call mplayer#send_command('seek 100 1')
endfunction

function! mplayer#set_seek(pos)
  let l:lastchar = a:pos[len(a:pos) - 1]
  if l:lastchar ==# '%'
    call mplayer#send_command('seek ' . a:pos . ' 1')
  elseif l:lastchar ==# 's' || l:lastchar =~# '\d'
    call mplayer#send_command('seek ' . a:pos . ' 2')
  endif
endfunction

function! mplayer#set_volume(volume)
  call mplayer#send_command('volume ' . a:volume . ' 1')
endfunction

function! mplayer#set_speed(speed)
  call mplayer#send_command('speed_set ' . a:speed)
endfunction

function! mplayer#set_equalizer(band_str)
  if has_key(s:eq_presets, a:band_str)
    call mplayer#send_command('af_eq_set_bands ' . s:eq_presets[a:band_str])
  else
    call mplayer#send_command('af_eq_set_bands ' . a:band_str)
  endif
endfunction

function! mplayer#operate_with_key()
  if !mplayer#is_playing() | return | endif
  let l:key = getchar()
  while l:key != s:NRQ
    if type(l:key) == 0
      call s:PM.writeln(s:PROCESS_NAME, 'key_down_event ' . l:key)
    elseif has_key(s:KEY_ACTION_DICT, l:key)
      call s:PM.writeln(s:PROCESS_NAME, s:KEY_ACTION_DICT[l:key])
    endif
    let l:key = getchar()
  endwhile
  call s:PM.writeln(s:PROCESS_NAME, s:DUMMY_COMMAND)
  call s:read(s:WAIT_TIME)
endfunction

function! mplayer#show_file_info()
  if !mplayer#is_playing() | return | endif
  call s:PM.writeln(s:PROCESS_NAME, s:DUMMY_COMMAND)
  for l:cmd in s:INFO_COMMANDS
    call s:PM.writeln(s:PROCESS_NAME, l:cmd)
  endfor
  let l:text = substitute(iconv(s:read(), &tenc, &enc), "'", '', 'g')
  let l:answers = map(split(l:text, "\n"), 'substitute(v:val, "^ANS_\\(.*\\)=\\(.*\\)", "\\1: \\2", "g")')
  echo join(l:answers, "\n")
endfunction

function! mplayer#show_cmdlist()
  if s:PM.is_available()
    echo vimproc#system(g:mplayer#command . ' -input cmdlist')
  else
    echoerr 'Error: vimproc is unavailable.'
  endif
endfunction

function! mplayer#flush()
  if !mplayer#is_playing() | return | endif
  let l:r = s:PM.read(s:PROCESS_NAME, [])
  if l:r[0] != ''
    echo '[stdout]'
    echo l:r[0]
  endif
  if l:r[1] != ''
    echo '[stderr]'
    echo l:r[1]
  endif
endfunction

function! mplayer#cmd_complete(arglead, cmdline, cursorpos)
  if !exists('s:cmd_complete_cache')
    let l:cmdlist = vimproc#system(g:mplayer#command . ' -input cmdlist')
    let s:cmd_complete_cache = map(split(l:cmdlist, "\n"), 'split(v:val, "  *")[0]')
  endif
  return filter(s:cmd_complete_cache, 'v:val =~ "^" . a:arglead')
endfunction

function! mplayer#equlizer_complete(arglead, cmdline, cursorpos)
  return filter(keys(s:eq_presets), 'v:val =~ "^" . a:arglead')
endfunction


function! s:enqueue(loadcmds)
  for l:cmd in a:loadcmds
    call s:writeln(l:cmd)
  endfor
  call s:read(s:WAIT_TIME)
endfunction

function! s:writeln(cmd)
  call s:PM.writeln(s:PROCESS_NAME, s:DUMMY_COMMAND)
  call s:PM.writeln(s:PROCESS_NAME, a:cmd)
endfunction

function! s:read(...)
  let l:wait_time = get(a:, 1, 0.05)
  let l:pattern = get(a:, 2, [])
  let l:raw_text = s:PM.read_wait(s:PROCESS_NAME, l:wait_time, [])[0]
  return substitute(l:raw_text, s:DUMMY_PATTERN, '', 'g')
endfunction

function! s:make_loadcmds(args)
  let l:filelist = []
  for l:item in a:args
    if isdirectory(expand(l:item))
      let l:dir_items = split(globpath(l:item, '*'), "\n")
      for l:dir_item in l:dir_items
        if filereadable(l:dir_item)
          call add(l:filelist, s:process_file(l:dir_item))
        endif
      endfor
    elseif l:item =~# '^\(cdda\|cddb\|dvd\|file\|ftp\|gopher\|tv\|vcd\|http\|https\)://'
      call add(l:filelist, 'loadfile ' . l:item . ' 1')
    else
      call add(l:filelist, s:process_file(expand(l:item)))
    endif
  endfor
  return l:filelist
endfunction

function! s:process_file(file)
  return (a:file =~# '\.\(m3u\|m3u8\|pls\|wax\|wpl\)$' ? 'loadlist ' : 'loadfile ') . a:file . ' 1'
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
