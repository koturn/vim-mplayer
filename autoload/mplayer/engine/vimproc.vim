" ============================================================================
" FILE: vimproc.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:PM = vital#mplayer#new().import('ProcessManager')

let s:WAIT_TIME = 0.05
let s:MPlayerEngineVimproc = {}


function! mplayer#engine#vimproc#define() abort
  return copy(s:MPlayerEngineVimproc)
endfunction


function! s:MPlayerEngineVimproc.start(custom_option) abort
  if !executable(self.mplayer)
    throw '[vim-mplayer] Please install mplayer'
  endif
  if !s:PM.is_available()
    throw '[vim-mplayer] vimproc.vim is unavailable'
  endif
  call self.stop()
  let self.handle = 'mplayer-' . self.id
  call s:PM.touch(self.handle, join([self.mplayer, self.option, a:custom_option]))
  call self._read()
endfunction

function! s:MPlayerEngineVimproc.kill(custom_option) abort
  if !self.is_playing() | return | endif
  call s:PM.kill(self.handle)
endfunction

function! s:MPlayerEngineVimproc.is_playing() abort
  try
    let status = s:PM.status(self.handle)
    return status ==# 'inactive' || status ==# 'active'
  catch
    return 0
  endtry
endfunction

function! s:MPlayerEngineVimproc._read(...) abort
  let wait_time = a:0 > 0 ? a:1 : s:WAIT_TIME
  return s:PM.read_wait(self.handle, wait_time, [])[0]
endfunction

function! s:MPlayerEngineVimproc._write(text) abort
  call s:PM.write(self.handle, a:text)
endfunction

function! s:MPlayerEngineVimproc.flush() abort
  if !self.is_playing() | return | endif
  return s:PM.read(self.handle, [])
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
