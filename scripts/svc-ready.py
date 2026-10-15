#!/usr/bin/env python3
"""Measure service start-to-ready from a single warm client process.

usage: svc-ready.py API TOKEN WORKSPACE MODULE [N]
Prints per-iteration: POST latency, POST->first successful GET, and the
GET latency itself, then medians. Avoids process-spawn noise (curl/jq).
"""
import http.client, json, statistics, sys, time, urllib.parse

api, token, ws, module = sys.argv[1:5]
n = int(sys.argv[5]) if len(sys.argv) > 5 else 10
u = urllib.parse.urlparse(api)
H = {"Authorization": "Bearer " + token}


def req(conn, method, path, body=None):
    conn.request(method, path, body=body, headers=H)
    r = conn.getresponse()
    return r.status, r.read()


ctl = http.client.HTTPConnection(u.hostname, u.port)
req(ctl, "GET", "/healthz")
posts, readies, gets = [], [], []
for i in range(n):
    t0 = time.perf_counter()
    st, b = req(ctl, "POST", f"/v1/workspaces/{ws}/services", json.dumps({"module": module}))
    t1 = time.perf_counter()
    svc = json.loads(b)
    while True:
        try:
            c = http.client.HTTPConnection("127.0.0.1", svc["port"], timeout=5)
            g0 = time.perf_counter()
            c.request("GET", "/")
            c.getresponse().read()
            g1 = time.perf_counter()
            c.close()
            break
        except OSError:
            time.sleep(0.001)
    posts.append((t1 - t0) * 1e3)
    readies.append((g1 - t0) * 1e3)
    gets.append((g1 - g0) * 1e3)
    req(ctl, "DELETE", f"/v1/services/{svc['service_id']}")
    print(f"post {posts[-1]:7.2f} ms   ready {readies[-1]:7.2f} ms   first GET {gets[-1]:7.2f} ms")
med = statistics.median
print(f"median: post {med(posts):.2f} ms, start-to-ready {med(readies):.2f} ms, first GET {med(gets):.2f} ms")
