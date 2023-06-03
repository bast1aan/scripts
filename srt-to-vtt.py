#!/usr/bin/env python3

from __future__ import annotations

from collections.abc import Iterator
from dataclasses import dataclass, field
from functools import reduce

import sys
import io

import jinja2


def run() -> str:
	cues = _parse(
		_readfile(sys.stdin)
	)

	with open('srt-to-vtt.vtt.j2', 'r') as f:
		template = jinja2.Template(f.read()) 

	return template.render(
		cues=cues, 
		classes=reduce(
			lambda classes, cue: classes | {cue.cls} if cue.cls else classes,
			cues,
			set()
		)
	)
	
def _readfile(f: io.TextIOBase) -> Iterator[str]:
	for line in f:
		yield line


def _parse(lines: Iterator[str]) -> list[Cue]:
	@dataclass
	class _Cue:
		id: str = ''
		timeline: str = ''
		content: list[str] = field(default_factory=list)
		cls: str = ''
	
	def _parse_content(content: list[str]) -> tuple[str, str]:
		output = '\n'.join(content)
		# parse classes
		if output.startswith('[E]'):
			return output[3:], 'exp'
		return output, ''

	def _to_external_cue(cue: _Cue) -> Cue:
		content, cls = _parse_content(cue.content)
		return Cue(timeline=cue.timeline, content=content, cls=cls)


	def _lines_to_cues(lines: Iterator[str]) -> Iterator[_Cue]:
		_cue = None
		for line in lines:
			if line == '\n' or line == '':
				yield _cue
				if line == '':
					break
				_cue = None
				continue
			line = line.strip()
			if not _cue:
				_cue = _Cue()
			if not _cue.id:
				_cue.id = line
				continue
			if not _cue.timeline:
				_cue.timeline = line
				continue
			# else, content.
			_cue.content.append(line)
	
	return list(map(_to_external_cue, _lines_to_cues(lines)))


@dataclass(frozen=True)  # needs to be frozen, to be serializable for Jinja
class Cue:
	timeline: str
	content: str
	cls: str


if __name__ == '__main__':
	print(run())
