#!/usr/bin/env python3
"""Gera footstep/shoot WAV e trilha de catedral (WAV curto → OGG via ffmpeg)."""
import math
import os
import random
import struct
import subprocess
import wave

SR = 44100


def write_wav_mono(path: str, samples: list[float]) -> None:
	os.makedirs(os.path.dirname(path), exist_ok=True)
	with wave.open(path, "wb") as wf:
		wf.setnchannels(1)
		wf.setsampwidth(2)
		wf.setframerate(SR)
		for s in samples:
			v = int(max(-32767, min(32767, s * 32767)))
			wf.writeframes(struct.pack("<h", v))


def gen_cathedral_wav() -> list[float]:
	"""Loop curto (~8 s): acordes lentos + harmónicos (som tipo órgão / nave)."""
	duration = 8.0
	samples: list[float] = []
	chords = [
		(196.0, 246.94, 293.66),
		(174.61, 220.0, 261.63),
		(164.81, 207.65, 246.94),
		(155.56, 196.0, 233.08),
	]
	chord_len = 2.0
	t = 0.0
	dt = 1.0 / SR
	while t < duration:
		ci = int(t // chord_len) % len(chords)
		f1, f2, f3 = chords[ci]
		phase = (t % chord_len) / chord_len
		env = 0.5 + 0.5 * math.sin(math.pi * phase)
		s = 0.0
		for f in (f1, f2, f3):
			s += math.sin(2 * math.pi * f * t) * 0.12
			s += math.sin(2 * math.pi * f * 2 * t) * 0.06
			s += math.sin(2 * math.pi * f * 3 * t) * 0.03
		s *= 0.24 * env
		samples.append(s)
		t += dt
	return samples


def gen_footstep() -> list[float]:
	random.seed(42)
	dur = 0.055
	n = int(dur * SR)
	out: list[float] = []
	for i in range(n):
		env = 1.0 - (i / max(1, n - 1))
		env *= env
		out.append((random.random() * 2 - 1) * 0.32 * env)
	return out


def gen_shoot() -> list[float]:
	dur = 0.1
	n = int(dur * SR)
	out: list[float] = []
	for i in range(n):
		t = i / SR
		f = 150.0 + 100.0 * math.exp(-t * 20)
		env = math.exp(-t * 32)
		out.append(math.sin(2 * math.pi * f * t) * env * 0.42)
	return out


def gen_wind() -> list[float]:
	"""Ruído suave (tipo vento) ~3,5 s, bom para loop curto."""
	random.seed(43)
	duration = 3.5
	n = int(duration * SR)
	out: list[float] = []
	prev = 0.0
	for i in range(n):
		white = random.random() * 2.0 - 1.0
		prev = 0.985 * prev + 0.015 * white
		t = i / SR
		slow = 0.32 + 0.08 * math.sin(t * 1.7) + 0.05 * math.sin(t * 5.3)
		out.append(prev * slow * 0.5)
	return out


def main() -> None:
	root = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
	os.makedirs(root, exist_ok=True)
	tmp_wav = os.path.join(root, "_cathedral_temp.wav")
	out_ogg = os.path.join(root, "cathedral_amb.ogg")

	write_wav_mono(tmp_wav, gen_cathedral_wav())
	write_wav_mono(os.path.join(root, "footstep.wav"), gen_footstep())
	write_wav_mono(os.path.join(root, "shoot.wav"), gen_shoot())
	write_wav_mono(os.path.join(root, "wind.wav"), gen_wind())

	# OGG: melhor loop e menor tamanho no Godot
	try:
		subprocess.run(
			[
				"ffmpeg",
				"-y",
				"-i",
				tmp_wav,
				"-c:a",
				"libvorbis",
				"-q:a",
				"4",
				out_ogg,
			],
			check=True,
			capture_output=True,
		)
	finally:
		if os.path.isfile(tmp_wav):
			os.remove(tmp_wav)

	print("gen_game_audio:", root, "→ cathedral_amb.ogg + footstep.wav + shoot.wav + wind.wav")


if __name__ == "__main__":
	main()
