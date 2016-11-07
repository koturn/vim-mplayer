"""
FILE: mplayer.vim
AUTHOR: koturn <jeak.koutan.apple@gmail.com>
DESCRIPTION: {{{
Mplayer frontend of Vim.
This file is a extension for unite.vim and provides denite-source.
denite.nvim: https://github.com/Shougo/denite.nvim
}}}
"""

from .base import Base
import glob
import itertools
import os
import platform


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'mplayer'
        self.kind = 'mplayer'

    def on_close(self, context):
        self.vim.call('mplayer#denite#stop')

    def gather_candidates(self, context):
        path = os.path.abspath(os.path.expanduser((context['args'][0] if len(context['args']) > 0 else self.vim.eval('g:mplayer#default_dir'))))
        if path[-1] != '/':
            path += '/'
        path_length = len(path)
        suffixes = self.vim.eval("get(g:, 'mplayer#suffixes', ['*'])")
        glob_patterns = ['*'] if len(suffixes) == 0 else suffixes
        return list(map(
            lambda filepath: {
                'word': filepath[path_length: ],
                'action__path': filepath},
            self.__glob(path, glob_patterns)))

    def __glob(self, path, glob_patterns):
        ver_tuple = list(map(int, platform.python_version_tuple()))
        if ver_tuple[0] > 3 or ver_tuple[0] == 3 and ver_tuple[1] > 4:
            return itertools.chain.from_iterable(
                    map(lambda glob_pattern: glob.glob(path + '**/*.' + glob_pattern, recursive=True), glob_patterns))
        else:
            return self.vim.call('globpath', path + '**', '*.{' + ','.join(glob_patterns) + '}', 1, 1)
