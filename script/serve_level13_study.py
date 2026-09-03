#!/usr/bin/env python3

import argparse
import http.server
import pathlib
import re
import urllib.parse


class StudyHandler(http.server.SimpleHTTPRequestHandler):
    observer_path: pathlib.Path

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_GET(self):
        path = urllib.parse.urlsplit(self.path).path
        if path == "/__windyfall_level13_observer.js":
            self._send_file(self.observer_path, "text/javascript; charset=utf-8")
            return
        if path in ("/", "/index.html"):
            index_path = pathlib.Path(self.directory) / "index.html"
            html = index_path.read_text(encoding="utf-8")
            html = re.sub(
                r"\s*<!-- GoatCounter \(visitor counter\) -->.*?"
                r"<!-- GlitchTip \(exception tracker\) -->\s*"
                r"<script.*?</script>",
                "",
                html,
                flags=re.DOTALL,
            )
            injection = (
                '<script src="/__windyfall_level13_observer.js"></script>\n'
                "</body>"
            )
            html = html.replace("</body>", injection)
            payload = html.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
            return
        super().do_GET()

    def _send_file(self, path: pathlib.Path, content_type: str):
        payload = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


def main():
    parser = argparse.ArgumentParser(
        description="Serve a Level 13 checkout with local WindyFall study instrumentation."
    )
    parser.add_argument("--level13", default=r"G:\level13")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", default=8130, type=int)
    args = parser.parse_args()

    root = pathlib.Path(args.level13).resolve()
    observer = (
        pathlib.Path(__file__).resolve().parent.parent
        / "research"
        / "level13"
        / "observer.js"
    )
    if not (root / "index.html").is_file():
        parser.error(f"Level 13 index not found under {root}")
    if not observer.is_file():
        parser.error(f"observer not found at {observer}")

    handler = lambda *handler_args, **handler_kwargs: StudyHandler(
        *handler_args, directory=str(root), **handler_kwargs
    )
    StudyHandler.observer_path = observer
    server = http.server.ThreadingHTTPServer((args.host, args.port), handler)
    print(f"Level 13 study server: http://{args.host}:{args.port}/")
    print("Press Ctrl+C to stop. The Level 13 checkout is served read-only.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
