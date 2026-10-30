"""Bounded iTerm2 previews and explicit erasure through tmux passthrough."""
import os
import subprocess
import sys
from ranger.ext.img_display import ITerm2ImageDisplayer, register_image_displayer


def passthrough(sequence):
    if os.environ.get('TMUX'):
        return '\033Ptmux;' + sequence.replace('\033', '\033\033') + '\033\\'
    return sequence


@register_image_displayer('iterm2')
class TmuxITerm2ImageDisplayer(ITerm2ImageDisplayer):
    def _generate_iterm2_input(self, path, max_cols, max_rows):
        if max_cols <= 0 or max_rows <= 0:
            return ''
        content = self._encode_image_content(path)
        # Cell bounds avoid guessing the font's pixel size (including Retina).
        sequence = ('\033]1337;File=inline=1;preserveAspectRatio=1;'
                    'size={};width={};height={}:{}\a').format(
                        os.path.getsize(path), int(max_cols), int(max_rows), content)
        return passthrough(sequence)

    def clear(self, start_x, start_y, width, height):
        if width <= 0 or height <= 0:
            return
        left = top = 0
        if os.environ.get('TMUX'):
            pane = os.environ.get('TMUX_PANE')
            if not pane:
                return super().clear(start_x, start_y, width, height)
            try:
                offsets = subprocess.check_output(
                    ['tmux', 'display-message', '-p', '-t', pane,
                     '#{pane_left} #{pane_top}'], timeout=1,
                    stderr=subprocess.DEVNULL).decode().split()
                left, top = map(int, offsets)
            except (OSError, ValueError, subprocess.SubprocessError):
                return super().clear(start_x, start_y, width, height)
        # tmux doesn't track passthrough images, and can optimize away curses'
        # blank-to-blank redraw. Erase the preview rectangle in iTerm itself.
        sequence = '\0337'
        for row in range(start_y + top, start_y + top + height):
            sequence += '\033[{};{}H\033[{}X'.format(row + 1, start_x + left + 1, width)
        sequence += '\0338'
        sys.stdout.write(passthrough(sequence))
        sys.stdout.flush()
