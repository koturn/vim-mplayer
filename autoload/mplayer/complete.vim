" ============================================================================
" FILE: complete.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Mplayer frontend of Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:eq_presets = {
      \ 'acoustic': '0:1:2:0:0:0:0:0:2:2',
      \ 'bass': '3:2:1:0:-1:-2:-3:-4:-5:-6',
      \ 'blues': '-1:0:2:1:0:0:0:0:-1:-3',
      \ 'boost': '-1:1:3:2:1:1:2:3:1:-1',
      \ 'classic': '-3:3:3:0:-3:-3:-3:-3:-1:-1',
      \ 'country': '-1:0:0:2:2:0:0:0:3:3',
      \ 'dance': '-3:2:3:-1:-3:-3:-2:-2:2:2',
      \ 'eargasm': '-5:-2:1:-1:-2:-3:-1:-4:3:0',
      \ 'folk': '-1:0:1:0:2:0:0:0:2:0',
      \ 'grunge': '-4:0:0:-2:0:0:2:3:0:-3',
      \ 'jazz': '-1:-1:-1:2:2:2:-1:1:3:3',
      \ 'koturn': '0:1:3:2:1:0:1:2:1:0',
      \ 'metal': '-4:0:0:0:0:0:3:0:3:1',
      \ 'new_age': '0:3:3:0:0:0:0:0:1:1',
      \ 'normal': '2:2:2:2:2:2:2:2:2:2',
      \ 'normalZero': '0:0:0:0:0:0:0:0:0:0',
      \ 'oldies': '-2:0:2:1:0:0:0:0:-2:-5',
      \ 'opera': '-2:-2:-2:1:2:0:3:0:-2:-2',
      \ 'perfect': '-5:-2:1:-1:-2:-3:-1:1:3:0',
      \ 'rap': '-4:-3:-1:-1:-4:-4:-3:-3:1:3',
      \ 'reggae': '-2:-1:-1:-4:-1:2:3:-1:2:3',
      \ 'rock': '-2:0:1:2:-2:-2:-1:-1:3:3',
      \ 'speech': '-2:0:2:1:0:0:0:0:-2:-5',
      \ 'swing': '-2:-1:-1:-1:2:2:-1:1:3:3',
      \ 'techno': '-8:-1:2:-3:-3:-4:-2:-2:3:3',
      \}

let s:SUB_ARG_DICT = {}
let s:SUB_ARG_DICT.dvdnav = sort([
      \ 'up', 'down', 'left', 'right',
      \ 'menu', 'select', 'prev', 'mouse'
      \])
let s:SUB_ARG_DICT.menu = sort(['up', 'down', 'ok', 'cancel', 'hide'])
let s:SUB_ARG_DICT.step_property = sort([
      \ 'osdlevel',
      \ 'speed', 'loop',
      \ 'chapter',
      \ 'angle',
      \ 'percent_pos', 'time_pos',
      \ 'volume', 'balance', 'mute',
      \ 'audio_delay',
      \ 'switch_audio', 'switch_angle', 'switch_title',
      \ 'capturing', 'fullscreen', 'deinterlace',
      \ 'ontop', 'rootwin',
      \ 'border', 'framedropping',
      \ 'gamma', 'brightness', 'contrast', 'saturation',
      \ 'hue', 'panscan', 'vsync',
      \ 'switch_video', 'switch_program',
      \ 'sub', 'sub_source', 'sub_file', 'sub_vob', 'sub_demux', 'sub_delay',
      \ 'sub_pos', 'sub_alignment', 'sub_visibility',
      \ 'sub_forced_only', 'sub_scale',
      \ 'tv_brightness', 'tv_contrast', 'tv_saturation', 'tv_hue',
      \ 'teletext_page', 'teletext_subpage', 'teletext_mode',
      \ 'teletext_format', 'teletext_half_page'
      \])
let s:SUB_ARG_DICT.set_property = sort(s:SUB_ARG_DICT.step_property + ['stream_pos'])
let s:SUB_ARG_DICT.get_property = sort(s:SUB_ARG_DICT.set_property + [
      \ 'pause',
      \ 'filename', 'path',
      \ 'demuxer',
      \ 'stream_start', 'stream_end', 'stream_length', 'stream_time_pos',
      \ 'chapters', 'length',
      \ 'metadata', 'metadata/album', 'metadata/artist', 'metadata/comment',
      \ 'metadata/genre', 'metadata/title', 'metadata/track','metadata/year',
      \ 'audio_format', 'audio_codec', 'audio_bitrate',
      \ 'samplerate', 'channels',
      \ 'video_format', 'video_codec', 'video_bitrate',
      \ 'width', 'height', 'fps', 'aspect'
      \])
lockvar s:SUB_ARG_DICT

let s:HELP_DICT = {
      \ 'cmdlist': '-input cmdlist',
      \ 'af': '-af help',
      \ 'ao': '-ao help',
      \ 'vf': '-vf help',
      \ 'vo': '-vo help'
      \}
lockvar s:HELP_DICT



function! mplayer#complete#cmd(arglead, cmdline, cursorpos) abort
  if !exists('s:cmd_complete_cache')
    let cmdlist = s:P.system(g:mplayer#mplayer . ' -input cmdlist')
    let s:cmd_complete_cache = sort(map(split(cmdlist, "\n"), 'split(v:val, " \\+")[0]'))
  endif
  let args = split(split(a:cmdline, '[^\\]\zs|')[-1], '\s\+')
  let nargs = len(args)
  let candidates = []
  if has_key(s:SUB_ARG_DICT, args[-1])
    let candidates = s:SUB_ARG_DICT[args[-1]]
  elseif nargs == 3 && a:arglead !=# '' && has_key(s:SUB_ARG_DICT, args[-2])
    let candidates = s:SUB_ARG_DICT[args[-2]]
  elseif nargs == 1 || (nargs == 2 && a:arglead !=# '')
    let candidates = s:cmd_complete_cache
  endif
  return s:match_filter(copy(candidates), a:arglead)
endfunction

function! mplayer#complete#step_property(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(copy(s:SUB_ARG_DICT.step_property), a:arglead, a:cmdline)
endfunction

function! mplayer#complete#get_property(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(copy(s:SUB_ARG_DICT.get_property), a:arglead, a:cmdline)
endfunction

function! mplayer#complete#set_property(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(copy(s:SUB_ARG_DICT.set_property), a:arglead, a:cmdline)
endfunction

function! mplayer#complete#equlizer(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(sort(keys(s:eq_presets)), a:arglead, a:cmdline)
endfunction

function! mplayer#complete#help(arglead, cmdline, cursorpos) abort
  return s:first_arg_complete(sort(keys(s:HELP_DICT)), a:arglead, a:cmdline)
endfunction

function! mplayer#complete#_import_local_vars(dict, ...) abort
  let attr = get(a:, 1, 'force')
  call extend(a:dict, s:, attr)
endfunction


function! s:first_arg_complete(candidates, arglead, cmdline) abort
  let nargs = len(split(split(a:cmdline, '[^\\]\zs|')[-1], '\s\+'))
  if nargs == 1 || (nargs == 2 && a:arglead !=# '')
    return s:match_filter(a:candidates, a:arglead)
  endif
endfunction

function! s:match_filter(candidates, arglead) abort
  let arglead = tolower(a:arglead)
  return filter(a:candidates, '!stridx(tolower(v:val), arglead)')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
