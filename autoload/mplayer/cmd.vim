" ============================================================================
" FILE: mplayer.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Mplayer frontend of Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:mplayer = mplayer#new()

function! mplayer#cmd#play(...) abort
  call s:mplayer.play(a:000)
endfunction

function! mplayer#cmd#enqueue(...) abort
  call s:mplayer.enqueue(a:000)
endfunction

function! mplayer#cmd#stop() abort
  call s:mplayer.stop()
endfunction

function! mplayer#cmd#prev(...) abort
  echo s:mplayer.prev(a:000)
endfunction

function! mplayer#cmd#next(...) abort
  echo s:mplayer.next(a:000)
endfunction

function! mplayer#cmd#command(cmd) abort
  echo s:mplayer.command(a:cmd)
endfunction

function! mplayer#cmd#set_speed(speed, is_scaletempo) abort
  for text in s:mplayer(a:speed, a:is_scaletempo)
    echo text
  endfor
endfunction

function! mplayer#cmd#set_equalizer(band_str) abort
  call s:mplayer.set_equalizer(a:band_str)
endfunction

function! mplayer#cmd#toggle_rt_timeinfo() abort
  call s:mplayer.toggle_rt_timeinfo()
endfunction

function! mplayer#cmd#set_seek(pos) abort
  call s:mplayer.set_seek(a:pos)
endfunction

function! mplayer#cmd#operate_with_key() abort
  call s:mplayer.operate_with_key()
endfunction

function! mplayer#cmd#show_file_info() abort
  let file_info = s:mplayer.get_file_info()
  if empty(file_info) | return | endif
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

function! mplayer#cmd#help(...) abort
  call mplayer#help()
endfunction

function! mplayer#cmd#flush() abort
  let r = s:mplayer.flush()
  if r[0] !=# ''
    echon "[stdout]\n" r[0]
  endif
  if r[1] !=# ''
    echon "[stderr]\n" r[1]
  endif
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




let &cpo = s:save_cpo
unlet s:save_cpo
