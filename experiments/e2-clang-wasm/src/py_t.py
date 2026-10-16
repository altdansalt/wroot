import sys, platform, unittest, json, hashlib, re, decimal
print(sys.version, sys.platform, platform.machine())
class T(unittest.TestCase):
    def test_json(self): self.assertEqual(json.loads("[1,2]"), [1,2])
    def test_hash(self): self.assertEqual(hashlib.sha256(b"x").hexdigest()[:8], "2d711642")
unittest.main(argv=["t"], exit=False, verbosity=2)
try:
    import socket; print("socket ok", hasattr(socket, "socket"))
    import threading; print("threading ok")
    import sqlite3; print("sqlite3 ok")
except Exception as e: print("import err", type(e).__name__, e)
