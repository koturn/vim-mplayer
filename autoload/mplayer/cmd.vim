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

function! mplayer#cmd#prev(...) abort
  call call(s:mplayer.prev, a:000, s:mplayer)
endfunction

function! mplayer#cmd#next(...) abort
  call call(s:mplayer.next, a:000, s:mplayer)
endfunction

function! mplayer#cmd#command(cmd) abort
  echo s:mplayer.command(a:cmd)
endfunction

function! mplayer#cmd#set_loop(n) abort
  call s:mplayer.set_loop(a:n)
endfunction

function! mplayer#cmd#set_volume(level) abort
  call call(s:mplayer.set_volume, a:level, s:mplayer)
endfunction

function! mplayer#cmd#set_seek(pos) abort
  call s:mplayer.set_seek(a:pos)
endfunction

function! mplayer#cmd#set_seek_to_head() abort
  call s:mplayer.set_seek_to_head()
endfunction

function! mplayer#cmd#set_seek_to_end() abort
  call s:mplayer.set_seek_to_end()
endfunction

function! mplayer#cmd#set_speed(speed, is_scaletempo) abort
  for text in s:mplayer.set_speed(a:speed, a:is_scaletempo)
    echo text
  endfor
endfunction

function! mplayer#cmd#set_equalizer(band_str) abort
  call s:mplayer.set_equalizer(a:band_str)
endfunction

function! mplayer#cmd#toggle_mute() abort
  call s:mplayer.toggle_mute()
endfunction

function! mplayer#cmd#toggle_pause() abort
  call s:mplayer.toggle_pause()
endfunction


function! mplayer#cmd#toggle_rt_timeinfo() abort
  if s:rt_sw
    call s:stop_rt_info()
  else
    call s:start_rt_info()
  endif
  let s:rt_sw = !s:rt_sw
endfunction

function! mplayer#cmd#operate_with_key() abort
  call s:mplayer.operate_with_key()
endfunction

function! mplayer#cmd#show_file_info() abort
  let file_info = s:mplayer.get_file_info()
  if empty(file_info)
    echoerr 'Failed to get file information'
    return
  endif
  let meta = file_info.meta
  let audio = file_info.audio
  let video = file_info.video
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

function! mplayer#cmd#seekbar() abort
  noautocmd botright 2 new
  set nobuflisted bufhidden=unload buftype=nofile nonumber
  if &columns < 40
    echoerr 'column must be 30 or more'
  endif
  let offset = 17 + strlen('position')
  let max = &columns - (offset + 7)
  let level = max * str2nr(s:mplayer.command('get_percent_pos')) / 100
  let p = level * 100 / max
  let [winnr, c] = [winnr(), '']
  try
    while c != char2nr('q')
      call setline(1, printf('position (%3d / 100):   [%s]', p, repeat('|', level) . repeat(' ', max - level)))
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
      call s:mplayer.set_seek(p . '%')
    endwhile
  catch
    echoerr v:exception
  finally
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


if g:mplayer#_use_job
  if has('job')
    function! s:show_timeinfo() abort
      call ch_sendraw(s:mplayer.handle, join([
            \ s:DUMMY_COMMAND, 'get_time_pos', 'get_time_length', 'get_percent_pos'
            \], "\n") . "\n")
      let text = substitute(s:mplayer._read(), "'", '', 'g')
      let answers = map(split(text, s:LINE_BREAK), 'matchstr(v:val, "^ANS_.\\+=\\zs.*$")')
      if len(answers) == 3
        echo '[MPlayer] position:' s:to_timestr(answers[1]) '/' s:to_timestr(answers[0]) ' (' . answers[2] . '%)'
      endif
    endfunction
  elseif has('nvim')
    function! s:show_timeinfo() abort
      call jobsend(s:mplayer.handle, join([
            \ s:DUMMY_COMMAND, 'get_time_pos', 'get_time_length', 'get_percent_pos'
            \], "\n") . "\n")
      let text = substitute(s:mplayer._read(), "'", '', 'g')
      let answers = map(split(text, s:LINE_BREAK), 'matchstr(v:val, "^ANS_.\\+=\\zs.*$")')
      if len(answers) == 3
        echo '[MPlayer] position:' s:to_timestr(answers[1]) '/' s:to_timestr(answers[0]) ' (' . answers[2] . '%)'
      endif
    endfunction
  endif
else
  function! s:show_timeinfo() abort
    call s:PM.writeln(s:mplayer.handle, join([
          \ s:DUMMY_COMMAND, 'get_time_pos', 'get_time_length', 'get_percent_pos'
          \], "\n"))
    let text = substitute(s:mplayer._read(), "'", '', 'g')
    let answers = map(split(text, s:LINE_BREAK), 'matchstr(v:val, "^ANS_.\\+=\\zs.*$")')
    if len(answers) == 3
      echo '[MPlayer] position:' s:to_timestr(answers[1]) '/' s:to_timestr(answers[0]) ' (' . answers[2] . '%)'
    endif
  endfunction
endif


if g:mplayer#_use_timer
  let s:timer_id = -1

  function! s:start_rt_info() abort
    if !s:mplayer.is_playing() | return | endif
    let s:timer_id = timer_start(&updatetime, function('s:timer_update'), {'repeat': -1})
  endfunction

  function! s:stop_rt_info() abort
    call timer_stop(s:timer_id)
  endfunction

  function! s:timer_update(timer_id) abort
    call s:show_timeinfo()
  endfunction
else
  function! s:start_rt_info() abort
    if !s:mplayer.is_playing() | return | endif
    execute 'autocmd! MPlayer CursorHold,CursorHoldI * call s:update()'
  endfunction

  function! s:stop_rt_info() abort
    execute 'autocmd! MPlayer CursorHold,CursorHoldI'
  endfunction

  function! s:update() abort
    call s:show_timeinfo()
    call feedkeys(mode() ==# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
  endfunction
endif

function! s:to_timestr(secstr) abort
  let second = str2nr(a:secstr)
  let dec_part = str2float(a:secstr) - second
  let hour = second / 3600
  let second = second % 3600
  let minute = second / 60
  let second = second % 60
  return printf('%02d:%02d:%02d.%1d', hour, minute, second, float2nr(dec_part * 10))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
