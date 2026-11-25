#!/usr/bin/env python3
"""Application Health Checker.

Checks one or more URLs and reports UP or DOWN based on the HTTP status code.
Usage: python3 app_health_check.py https://example.com http://localhost:8080
Exit code is 0 if every app is UP, 1 otherwise.
"""
import sys
import time
import urllib.error
import urllib.request


def check(url: str, timeout: float = 5.0) -> tuple[bool, str]:
    start = time.time()
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "health-checker/1.0"})
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            code = resp.status
            ms = int((time.time() - start) * 1000)
            ok = 200 <= code < 400
            return ok, f"HTTP {code} in {ms}ms"
    except urllib.error.HTTPError as e:
        # Server answered, but with an error status (404, 500, ...)
        return False, f"HTTP {e.code} {e.reason}"
    except (urllib.error.URLError, TimeoutError, ConnectionError) as e:
        return False, f"no response ({e})"


def main() -> int:
    urls = sys.argv[1:]
    if not urls:
        print(__doc__)
        return 2
    all_up = True
    for url in urls:
        ok, detail = check(url)
        status = "UP  " if ok else "DOWN"
        print(f"[{status}] {url} - {detail}")
        all_up = all_up and ok
    return 0 if all_up else 1


if __name__ == "__main__":
    sys.exit(main())
