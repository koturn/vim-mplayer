" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:V = vital#mplayer#new()
let s:P = s:V.import('Process')
let s:PM = s:V.import('ProcessManager')
let s:DUMMY_COMMAND = mplayer#_import_local_var('DUMMY_COMMAND')
let s:LINE_BREAK = mplayer#_import_local_var('LINE_BREAK')
let s:HELP_DICT = mplayer#complete#_import_local_var('HELP_DICT')
let s:EXIT_KEYCODE = char2nr('q') | lockvar s:EXIT_KEYCODE
let s:KEY_ACTION_DICT = {
      \ "\<Left>": 'seek -10',
      \ "\<Right>": 'seek 10',
      \ "\<Up>": 'seek 60',
      \ "\<Down>": 'seek -60'
      \}
lockvar s:KEY_ACTION_DICT

let s:mplayer = mplayer#new()
let s:rt_sw = 0


function! mplayer#cmd#play(...) abort
  call call(s:mplayer.play, a:000, s:mplayer)
endfunction

function! mplayer#cmd#enqueue(...) abort
  call call(s:mplayer.enqueue, a:000, s:mplayer)
endfunction

function! mplayer#cmd#stop() abort
  call s:mplayer.stop()
endfunction

function! mplayer#cmd#kill() abort
  call s:mplayer.kill()
endfunction

function! mplayer#cmd#prev(...) abort
  echo call(s:mplayer.prev, a:000, s:mplayer)
endfunction

function! mplayer#cmd#next(...) abort
  echo call(s:mplayer.next, a:000, s:mplayer)
endfunction

function! mplayer#cmd#command(cmd) abort
  echo s:mplayer.command(a:cmd, 1)
endfunction

function! mplayer#cmd#set_loop(n) abort
  echo s:mplayer.set_loop(a:n)
endfunction

function! mplayer#cmd#set_volume(level) abort
  echo s:mplayer.set_volume(a:level)
endfunction

function! mplayer#cmd#set_seek(pos) abort
  echo s:mplayer.set_seek(a:pos)
endfunction

function! mplayer#cmd#set_seek_to_head() abort
  echo s:mplayer.set_seek_to_head()
endfunction

function! mplayer#cmd#set_seek_to_end() abort
  echo s:mplayer.set_seek_to_end()
endfunction

function! mplayer#cmd#set_speed(speed, is_scaletempo) abort
  for text in s:mplayer.set_speed(a:speed, a:is_scaletempo)
    echo text
  endfor
endfunction

function! mplayer#cmd#set_equalizer(band_str) abort
  echo s:mplayer.set_equalizer(a:band_str)
endfunction

function! mplayer#cmd#toggle_mute() abort
  echo s:mplayer.toggle_mute()
endfunction

function! mplayer#cmd#toggle_pause() abort
  echo s:mplayer.toggle_pause()
endfunction

function! mplayer#cmd#toggle_rt_timeinfo() abort
  let [_, s:rt_sw] = [s:rt_sw ? s:stop_rt_info() : s:start_rt_info(), !s:rt_sw]
endfunction

function! mplayer#cmd#operate_with_key() abort
  if !s:mplayer.is_playing() | return | endif
  echo "Type 'q' to exit this mode"
  let key = getchar()
  while key isnot s:EXIT_KEYCODE
    if type(key) == 0
      call s:mplayer._write('key_down_event ' . key . "\n")
    elseif has_key(s:KEY_ACTION_DICT, key)
      call s:mplayer._write(s:KEY_ACTION_DICT[key] . "\n")
    endif
    let key = getchar()
  endwhile
  call s:mplayer._write(s:DUMMY_COMMAND . "\n")
  call s:mplayer._read()
endfunction

function! mplayer#cmd#show_file_info() abort
  let file_info = s:mplayer.get_file_info()
  if empty(file_info)
    echoerr 'Failed to get file information'
    return
  endif
  let [meta, audio, video] = [file_info.meta, file_info.audio, file_info.video]
  echo '[STANDARD INFORMATION]'
  echo '  posiotion: ' s:to_timestr(file_info.time_length) '/' s:to_timestr(file_info.time_pos) ' (' . file_info.percent_pos . '%)'
  echo '  filename:  ' file_info.filename
  echo '[META DATA]'
  echo '  title:     ' meta.title
  echo '  artist:    ' meta.artist
  echo '  album:     ' meta.album
  echo '  year:      ' meta.year
  echo '  comment:   ' meta.comment
  echo '  track:     ' meta.track
  echo '  genre:     ' meta.genre
  echo '[AUDIO]'
  echo '  codec:     ' audio.codec
  echo '  bitrate:   ' audio.bitrate
  echo '  sample:    ' audio.sample
  if video.codec !=# '' && video.bitrate !=# '' && video.resolution !=# ''
    echo '[VIDEO]'
    echo '  codec:     ' video.codec
    echo '  bitrate:   ' video.bitrate
    echo '  resolution:' video.resolution
  endif
endfunction

function! mplayer#cmd#volumebar() abort
  noautocmd botright 2 new
  set nobuflisted bufhidden=unload buftype=nofile nonumber
  if &columns < 40
    echoerr 'column must be 30 or more'
  endif
  let offset = 15 + strlen('volume')
  let max = &columns - (offset + 7)
  let level = max * str2nr(s:mplayer.command('get_property volume')) / 100
  let p = level * 100 / max
  let [winnr, c] = [winnr(), '']
  echomsg "Type 'q' to quit"
  try
    while c isnot char2nr('q')
      call setline(1, printf('volume (%3d / 100): [%s]', p, repeat('|', level) . repeat(' ', max - level)))
      redraw
      let c = getchar()
      if c is# "\<LeftMouse>" && v:mouse_win == winnr
        let level = v:mouse_col - offset
      elseif c is char2nr('h')
        let level -= 1
      elseif c is char2nr('l')
        let level += 1
      endif
      let level = level > max ? max : level < 0 ? 0 : level
      let p = level * 100 / max
      call s:mplayer.set_volume(p)
    endwhile
  catch
    echoerr v:exception
  finally
    quit
  endtry
endfunction

function! mplayer#cmd#seekbar() abort
  if !has('timers')
    throw '[vim-mplayer] mplayer#cmd#seekbar() requires timer-feature'
  endif
  noautocmd botright 2 new
  set nobuflisted bufhidden=unload buftype=nofile nonumber
  if &columns < 40
    echoerr 'column must be 30 or more'
  endif
  let offset = 15 + strlen('seek')
  let max = &columns - (offset + 7)
  let s:seekpos = max * str2nr(s:mplayer.command('get_percent_pos')) / 100
  let s:seek_percent = s:seekpos * 100 / max
  let [winnr, c] = [winnr(), '']
  call s:start_seekbar_timer()
  echomsg "Type 'q' to quit"
  try
    while c isnot char2nr('q')
      let c = s:getchar()
      if c is 0
        continue
      elseif c is# "\<LeftMouse>" && v:mouse_win == winnr
        let s:seekpos = v:mouse_col - offset
        let s:seek_percent = s:seekpos * 100 / max
        call s:mplayer._command('seek ' . s:seek_percent . ' 1')
      elseif c is char2nr('h')
        call s:mplayer._command('seek -10 0')
      elseif c is char2nr('l')
        call s:mplayer._command('seek 10 0')
      endif
      let s:seekpos = max * str2nr(s:mplayer.command('get_percent_pos')) / 100
      let s:seek_percent = s:seekpos * 100 / max
      call setline(1, printf('seek (%3d / 100): [%s]', s:seek_percent, repeat('|', s:seekpos) . repeat(' ', max - s:seekpos)))
      redraw
    endwhile
  catch
    echoerr v:exception
  finally
    call s:stop_seekbar_timer()
    quit
  endtry
endfunction

function! mplayer#cmd#help(...) abort
  let arg = get(a:, 1, 'cmdlist')
  if has_key(s:HELP_DICT, arg)
    echo s:P.system(g:mplayer#mplayer . ' ' . s:HELP_DICT[arg])
  endif
endfunction

function! mplayer#cmd#flush() abort
  let [stdout, stderr] = s:mplayer.flush()
  if stdout !=# ''
    echon "[stdout]\n" stdout
  endif
  if stderr !=# ''
    echon "[stderr]\n" stderr
  endif
endfunction


function! s:show_timeinfo() abort
  let text = substitute(s:mplayer._command(join(['get_time_pos', 'get_time_length', 'get_percent_pos'], "\n")), "'", '', 'g')
  let answers = map(split(text, s:LINE_BREAK), 'matchstr(v:val, "^ANS_.\\+=\\zs.*$")')
  if len(answers) == 3
    echo '[MPlayer] position:' s:to_timestr(answers[1]) '/' s:to_timestr(answers[0]) ' (' . answers[2] . '%)'
  endif
endfunction

if g:mplayer#_use_timer
  let s:timer_id = -1

  function! s:start_rt_info() abort
    if !s:mplayer.is_playing() | return | endif
    let s:timer_id = timer_start(g:mplayer#tiemr_cycle, function('s:rt_update'), {'repeat': -1})
  endfunction

  function! s:stop_rt_info() abort
    call timer_stop(s:timer_id)
  endfunction

  function! s:rt_update(timer_id) abort
    call s:show_timeinfo()
  endfunction


  let s:seekbar_timer_id = -1

  function! s:start_seekbar_timer() abort
    if !s:mplayer.is_playing() | return | endif
    let s:seekbar_timer_id = timer_start(g:mplayer#tiemr_cycle, function('s:seekbar_update'), {'repeat': -1})
  endfunction

  function! s:stop_seekbar_timer() abort
    call timer_stop(s:seekbar_timer_id)
  endfunction

  function! s:seekbar_update(seekbar_timer_id) abort
    let offset = 15 + strlen('seek')
    let max = &columns - (offset + 7)
    let s:seekpos = max * str2nr(s:mplayer.command('get_percent_pos')) / 100
    let s:seek_percent = s:seekpos * 100 / max
    call setline(1, printf('seek (%3d / 100): [%s]', s:seek_percent, repeat('|', s:seekpos) . repeat(' ', max - s:seekpos)))
    redraw
  endfunction
else
  augroup MPlayer
    autocmd!
  augroup END

  function! s:start_rt_info() abort
    if !s:mplayer.is_playing() | return | endif
    execute 'autocmd! MPlayer CursorHold,CursorHoldI * call s:update()'
  endfunction

  function! s:stop_rt_info() abort
    execute 'autocmd! MPlayer CursorHold,CursorHoldI'
  endfunction

  let s:clock = 0
  function! s:update() abort
    call feedkeys(mode() ==# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
    if  s:clock < g:mplayer#tiemr_cycle
      let s:clock += &updatetime
    else
      let s:clock = 0
      call s:show_timeinfo()
    endif
  endfunction
endif

function! s:to_timestr(secstr) abort
  let second = str2nr(a:secstr)
  let dec_part = str2float(a:secstr) - second
  let [hour, second] = [second / 3600, second % 3600]
  let [minute, second] = [second / 60, second % 60]
  return printf('%02d:%02d:%02d.%1d', hour, minute, second, float2nr(dec_part * 10))
endfunction

if has('nvim')
  function! s:getchar() abort
    let c = getchar(0)
    if c is 0
      sleep 50m
      return 0
    else
      return c
    endif
  endfunction
else
  let s:getchar = function('getchar')
endif


let &cpo = s:save_cpo
unlet s:save_cpo
