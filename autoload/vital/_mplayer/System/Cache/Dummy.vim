" ___vital___
" NOTE: lines between '" ___vital___' is generated by :Vitalize.
" Do not mofidify the code nor insert new lines before '" ___vital___'
function! s:_SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
endfunction
execute join(['function! vital#_mplayer#System#Cache#Dummy#import() abort', printf("return map({'_vital_depends': '', 'new': '', '_vital_loaded': ''}, \"vital#_mplayer#function('<SNR>%s_' . v:key)\")", s:_SID()), 'endfunction'], "\n")
delfunction s:_SID
" ___vital___
let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V) abort
  let s:Base = a:V.import('System.Cache.Base')
endfunction
function! s:_vital_depends() abort
  return ['System.Cache.Base']
endfunction

let s:cache = {
      \ '__name__': 'dummy',
      \}
function! s:new(...) abort
  return extend(
        \ call(s:Base.new, a:000, s:Base),
        \ deepcopy(s:cache)
        \)
endfunction

function! s:cache.has(name) abort
  return 0
endfunction
function! s:cache.get(name, ...) abort
  return get(a:000, 0, '')
endfunction
function! s:cache.set(name, value) abort
  " do nothing
endfunction
function! s:cache.keys() abort
  return []
endfunction
function! s:cache.remove(name) abort
  " do nothing
endfunction
function! s:cache.clear() abort
  " do nothing
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
"vim: sts=2 sw=2 smarttab et ai textwidth=0 fdm=marker
