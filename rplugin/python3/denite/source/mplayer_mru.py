"""
FILE: mplayer.py
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
        self.name = 'mplayer_mru'
        self.kind = 'mplayer'

    def on_close(self, context):
        self.vim.call('mplayer#denite#stop')

    def gather_candidates(self, context):
        return list(map(
            lambda candidates: {
                'word': candidates,
                'action__path': candidates},
            self.vim.eval('mplayer#cmd#get_mru_list()')))
