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
  call s:mplayer.prev(a:000)
endfunction

function! mplayer#cmd#next(...) abort
  call s:mplayer.next(a:000)
endfunction

function! mplayer#cmd#command(cmd) abort
  call s:mplayer.command(a:cmd)
endfunction

function! mplayer#cmd#set_speed(speed, is_scaletempo) abort
  call s:mplayer(a:speed, a:is_scaletempo)
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
  call s:mplayer.show_file_info()
endfunction

function! mplayer#cmd#help(...) abort
  call s:mplayer.help()
endfunction

function! mplayer#cmd#flush() abort
  call s:mplayer.flush()
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
