" ============================================================================
" FILE: vimproc.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim

" {{{ Constants
let s:WAIT_TIME = 0.05
" }}}


function! mplayer#engine#vimproc#define() abort " {{{
  return copy(s:MPlayerEngineVimproc)
endfunction " }}}


let s:MPlayerEngineVimproc = {} " {{{

function! s:MPlayerEngineVimproc.start(custom_option) abort " {{{
  if !executable(self.mplayer)
    throw '[vim-mplayer] Please install mplayer'
  endif
  if !mplayer#util#_has_vimproc()
    throw '[vim-mplayer] vimproc.vim is unavailable'
  endif
  call self.stop()
  let self.handle = 'mplayer-' . self.id
  call s:touch(self.handle, join([self.mplayer, self.option, a:custom_option]))
  sleep 100m
  call self._read()
endfunction " }}}

function! s:MPlayerEngineVimproc.kill(custom_option) abort " {{{
  if !self.is_playing() | return | endif
  call s:kill(self.handle)
endfunction " }}}

function! s:MPlayerEngineVimproc.is_playing() abort " {{{
  try
    let status = s:status(self.handle)
    return status ==# 'inactive' || status ==# 'active'
  catch
    return 0
  endtry
endfunction " }}}

function! s:MPlayerEngineVimproc._read(...) abort " {{{
  let wait_time = a:0 > 0 ? a:1 : s:WAIT_TIME
  return s:read_wait(self.handle, wait_time, [])[0]
endfunction " }}}

function! s:MPlayerEngineVimproc._write(text) abort " {{{
  call s:write(self.handle, a:text)
endfunction " }}}

function! s:MPlayerEngineVimproc.flush() abort " {{{
  if !self.is_playing() | return | endif
  return s:read(self.handle, [])
endfunction " }}}
" }}}


let s:proc_dict = {}
let s:state = {}

function! s:touch(name, cmd) abort " {{{
  if has_key(s:proc_dict, a:name)
    return 'existing'
  else
    let s:proc_dict[a:name] = vimproc#popen3(a:cmd)
    return 'new'
  endif
endfunction " }}}

function! s:kill(i) abort " {{{
  call s:proc_dict[a:i].kill(g:vimproc#SIGKILL)
  unlet s:proc_dict[a:i]
  if has_key(s:state, a:i)
    unlet s:state[a:i]
  endif
endfunction " }}}

function! s:read(i, endpatterns) abort " {{{
  return s:read_wait(a:i, 0.05, a:endpatterns)
endfunction " }}}

function! s:read_wait(i, wait, endpatterns) abort " {{{
  if !has_key(s:proc_dict, a:i)
    throw printf("[vim-mplayer] Process is not exists: ID = %s", a:i)
  endif

  let p = s:proc_dict[a:i]

  if s:status(a:i) ==# 'inactive'
    let s:state[a:i] = 'inactive'
    return [p.stdout.read(), p.stderr.read(), 'inactive']
  endif

  let [out_memo, err_memo, lastchanged] = ['', '', reltime()]
  while 1
    let [x, y] = [p.stdout.read(-1, 0), p.stderr.read(-1, 0)]
    if x ==# '' && y ==# ''
      if str2float(reltimestr(reltime(lastchanged))) > a:wait
        let s:state[a:i] = 'reading'
        return [out_memo, err_memo, 'timedout']
      endif
    else
      let lastchanged = reltime()
      let out_memo .= x
      let err_memo .= y
      for pattern in a:endpatterns
        if out_memo =~ ("\\(^\\|\n\\)" . pattern)
          let s:state[a:i] = 'idle'
          return [s:S.substitute_last(out_memo, pattern, ''), err_memo, 'matched']
        endif
      endfor
    endif
  endwhile
endfunction " }}}

function! s:write(i, str) abort " {{{
  if !has_key(s:proc_dict, a:i)
    throw printf("[vim-mplayer] Process is not exists: ID = %s", a:i)
  endif
  if s:status(a:i) ==# 'inactive'
    return 'inactive'
  endif
  call s:proc_dict[a:i].stdin.write(a:str)
  return 'active'
endfunction " }}}

" vimproc.kill isn't to stop but to ask for the current state.
" return p.kill(0) ? 'inactive' : 'active'
" ... checkpid() checks if the process is running AND does waitpid() in C,
" so it solves zombie processes.
function! s:status(i) abort " {{{
  if !has_key(s:proc_dict, a:i)
    throw printf("[vim-mplayer] Process is not exists: ID = %s", a:i)
  endif
  return get(s:proc_dict[a:i].checkpid(), 0, '') ==# 'run' ? 'active' : 'inactive'
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
