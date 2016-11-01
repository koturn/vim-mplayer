" ============================================================================
" FILE: job.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" A mplayer frontend for Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:WAIT_TIME = 50
let s:MPlayerEngineJob = {}


function! mplayer#engine#job#define() abort
  return copy(s:MPlayerEngineJob)
endfunction


if has('nvim')
  function! s:on_stdout(id, data, e) abort dict
    let self.stdout .= join(a:data, "\n")
  endfunction

  function! s:on_stderr(id, data, e) abort dict
    let self.stderr .= join(a:data, "\n")
  endfunction

  function! s:MPlayerEngineJob.start(custom_option) abort
    if !executable(self.mplayer)
      throw '[vim-mplayer] Please install mplayer'
    endif
    call self.stop()
    let self.jobopt = {
          \ 'stdout': '',
          \ 'stderr': '',
          \ 'on_stdout': function('s:on_stdout'),
          \ 'on_stderr': function('s:on_stderr')
          \}
    let self.handle = jobstart(join([self.mplayer, self.option, a:custom_option]), self.jobopt)
    call self._read()
  endfunction

  function! s:MPlayerEngineJob.kill(custom_option) abort
    if !self.is_playing() | return | endif
    call jobstop(self.handle)
  endfunction

  function! s:MPlayerEngineJob.is_playing() abort
    try
      call jobpid(self.handle)
      return 1
    catch
      return 0
    endtry
  endfunction

  function! s:MPlayerEngineJob._read(...) abort
    let wait_time = a:0 > 0 ? a:1 : s:WAIT_TIME
    execute 'sleep' wait_time . 'm'
    let [raw_text, self.jobopt.stdout] = [self.jobopt.stdout, '']
    return raw_text
  endfunction

  function! s:MPlayerEngineJob._write(text) abort
    call jobsend(self.handle, a:text)
  endfunction

  function! s:MPlayerEngineJob.flush() abort
    if !self.is_playing() | return | endif
    let r = [self.jobopt.stdout, self.jobopt.stderr]
    let [self.jobopt.stdout, self.jobopt.stderr] = ['', '']
    return r
  endfunction
else
  function! s:MPlayerEngineJob.start(custom_option) abort
    if !executable(self.mplayer)
      throw '[vim-mplayer] Please install mplayer'
    endif
    call self.stop()
    let self.handle = job_start(join([self.mplayer, self.option, a:custom_option]), {
          \ 'out_mode': 'raw'
          \})
    call self._read()
  endfunction

  function! s:MPlayerEngineJob.kill(custom_option) abort
    if !self.is_playing() | return | endif
    call job_stop(self.handle)
  endfunction

  function! s:MPlayerEngineJob.is_playing() abort
    return has_key(self, 'handle') && job_status(self.handle) ==# 'run'
  endfunction

  function! s:MPlayerEngineJob._read(...) abort
    let wait_time = a:0 > 0 ? a:1 : s:WAIT_TIME
    return ch_readraw(self.handle, {'timeout': wait_time})
  endfunction

  function! s:MPlayerEngineJob._write(text) abort
    call ch_sendraw(self.handle, a:text)
  endfunction

  function! s:MPlayerEngineJob.flush() abort
    if !self.is_playing() | return | endif
    return [ch_readraw(self.handle, {'timeout': 0}), ch_readraw(self.handle, {'part': 'err', 'timeout': 0})]
  endfunction
endif


let &cpo = s:save_cpo
unlet s:save_cpo
