" ============================================================================
" FILE: util.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" Last Modified: 2018 12/02
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" Utility functions.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


if has('nvim')
  function! s:on_stdout(id, data, e) abort dict " {{{
    let self.out .= join(a:data, "\n")
  endfunction " }}}
  function! s:_system(arg) abort " {{{
    let jobopt = {
          \ 'out': '',
          \ 'on_stdout': function('s:on_stdout')
          \}
    call jobwait([jobstart(a:arg, jobopt)])
    return jobopt.out
  endfunction " }}}
  let s:system = function('s:_system')
elseif has('job')
  function! s:_system(cmd) abort " {{{
    let out = ''
    let job = job_start(a:cmd, {
          \ 'out_cb': {ch, msg -> [execute('let out .= msg'), out]},
          \ 'out_mode': 'raw'
          \})
    while job_status(job) ==# 'run'
      sleep 1m
    endwhile
    return out
  endfunction " }}}
  let s:system = function('s:_system')
elseif mplayer#util#_has_vimproc()
  let s:system = function('vimproc#cmd#system')
else
  let s:system = function('system')
endif

function! mplayer#util#_get_system_func() abort " {{{
  return s:system
endfunction " }}}

function! mplayer#util#_has_vimproc() abort " {{{
  return exists('s:exists_vimproc') ? s:exists_vimproc : s:has_vimproc()
endfunction " }}}

function! s:has_vimproc() abort " {{{
  try
    call vimproc#version()
    let s:exists_vimproc = 1
  catch
    let s:exists_vimproc = 0
  endtry
  return s:exists_vimproc
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
