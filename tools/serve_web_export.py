#!/usr/bin/env python3
"""Serve a pasta exportada para Web (Godot 4 + WASM).

Problemas comuns que isto evita:
- file:// não carrega WASM → usa sempre http://127.0.0.1:PORTA/
- python -m http.server não envia application/wasm → o browser recusa o .wasm

Uso:
  python3 tools/serve_web_export.py /pasta/do/export
  python3 tools/serve_web_export.py /pasta/do/export -p 8765
  python3 tools/serve_web_export.py /pasta/do/export --isolate

--isolate  → envia COOP/COEP (só necessário se o export Web usar threads /
             SharedArrayBuffer; se o jogo falhar com --isolate, tenta SEM.)

Depois abre no browser o HTML que o Godot gerou (ex.: Bellapps.html ou index.html).
"""
from __future__ import annotations

import argparse
import http.server
import os
import socketserver
import sys
from typing import Type


def _build_handler(with_isolation: bool) -> Type[http.server.SimpleHTTPRequestHandler]:
	class Handler(http.server.SimpleHTTPRequestHandler):
		extensions_map = {
			**http.server.SimpleHTTPRequestHandler.extensions_map,
			".wasm": "application/wasm",
			".js": "application/javascript",
			".mjs": "application/javascript",
			".pck": "application/octet-stream",
			".data": "application/octet-stream",
			".symbols": "text/plain",
		}

		def end_headers(self) -> None:
			if with_isolation:
				self.send_header("Cross-Origin-Opener-Policy", "same-origin")
				self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
			self.send_header("Cache-Control", "no-cache")
			super().end_headers()

	return Handler


def main() -> None:
	p = argparse.ArgumentParser(description="Servidor HTTP local para export Web do Godot.")
	p.add_argument(
		"directory",
		nargs="?",
		default=".",
		help="Pasta onde está o .html exportado (predefinição: diretório atual).",
	)
	p.add_argument(
		"-p",
		"--port",
		type=int,
		default=8765,
		help="Porta (predefinição: 8765).",
	)
	p.add_argument(
		"--isolate",
		action="store_true",
		help="Ativa cabeçalhos COOP/COEP (export com threads / SharedArrayBuffer).",
	)
	args = p.parse_args()

	directory = os.path.abspath(args.directory)
	if not os.path.isdir(directory):
		print(f"Erro: pasta não existe: {directory}", file=sys.stderr)
		sys.exit(1)

	os.chdir(directory)
	Handler = _build_handler(args.isolate)

	with socketserver.TCPServer(("", args.port), Handler) as httpd:
		files = [f for f in os.listdir(".") if f.endswith((".html", ".HTML"))]
		print(f"A servir: {directory}")
		print(f"URL base: http://127.0.0.1:{args.port}/")
		if files:
			for name in sorted(files):
				print(f"  → http://127.0.0.1:{args.port}/{name}")
		else:
			print("  (nenhum .html encontrado nesta pasta)")
		if args.isolate:
			print("Modo --isolate (COOP/COEP) ligado.")
		print("Ctrl+C para parar.")
		httpd.serve_forever()


if __name__ == "__main__":
	main()
