"""Threaded static server for creative rendering."""
import http.server
import socketserver
import os

PROJECT_ROOT = r"C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB"
PORT = 8733

class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

class ThreadedServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    daemon_threads = True
    allow_reuse_address = True

os.chdir(PROJECT_ROOT)
with ThreadedServer(("127.0.0.1", PORT), Handler) as httpd:
    print(f"serving {PROJECT_ROOT} on http://127.0.0.1:{PORT}", flush=True)
    httpd.serve_forever()
