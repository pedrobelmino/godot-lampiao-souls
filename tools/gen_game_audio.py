#!/usr/bin/env python3
"""Gera WAV simples para Godot: ambiente de catedral, passos, disparo."""
import math
import os
import random
import struct
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


def gen_cathedral() -> list[float]:
	"""~16 s, acordes lentos (estilo órgão / reverb implícito por harmónicos)."""
	duration = 16.0
	samples: list[float] = []
	chords = [
		(220.0, 261.63, 329.63),
		(196.0, 233.08, 293.66),
		(174.61, 220.0, 261.63),
		(164.81, 196.0, 246.94),
	]
	chord_len = 4.0
	t = 0.0
	dt = 1.0 / SR
	while t < duration:
		ci = int(t // chord_len) % len(chords)
		f1, f2, f3 = chords[ci]
		chord_phase = (t % chord_len) / chord_len
		env = 0.55 + 0.45 * math.sin(math.pi * chord_phase)
		s = 0.0
		for f in (f1, f2, f3):
			s += math.sin(2 * math.pi * f * t) * 0.14
			s += math.sin(2 * math.pi * f * 2 * t) * 0.07
			s += math.sin(2 * math.pi * f * 3 * t) * 0.035
		s *= 0.2 * env
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


def main() -> None:
	root = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
	write_wav_mono(os.path.join(root, "cathedral_amb.wav"), gen_cathedral())
	write_wav_mono(os.path.join(root, "footstep.wav"), gen_footstep())
	write_wav_mono(os.path.join(root, "shoot.wav"), gen_shoot())
	print("gen_game_audio:", root)


if __name__ == "__main__":
	main()
