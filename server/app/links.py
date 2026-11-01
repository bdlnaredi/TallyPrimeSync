"""Customer links: a private, read-only page for one party, where they see their own ledger, pending bills
and vouchers (with PDFs) any time. Kept in links.json next to the database, so a rebuilt database (a full
sync, a restored backup) doesn't break links already sent to customers."""
import json
import os
import secrets
import threading
import time

import store

PATH = os.path.join(os.path.dirname(store.DB_PATH), "links.json")
_lock = threading.Lock()


def _load():
    try:
        with open(PATH) as f:
            d = json.load(f)
            d.setdefault("links", {})
            d.setdefault("base", "")
            return d
    except (OSError, ValueError):
        return {"links": {}, "base": ""}


def _save(d):
    tmp = PATH + ".tmp"
    with open(tmp, "w") as f:
        json.dump(d, f, indent=1)
    os.replace(tmp, PATH)


def base():
    """The address customers open the links with (Settings, Customer links), or "" to use the app's own."""
    return _load().get("base", "")


def set_base(url):
    url = (url or "").strip().rstrip("/")
    if url and not url.startswith(("http://", "https://")):
        url = "https://" + url
    with _lock:
        d = _load()
        d["base"] = url
        _save(d)
    return url


def get(company, party, create=True):
    """The party's link token: the existing one, or a new one."""
    with _lock:
        d = _load()
        for tok, l in d["links"].items():
            if l["company"] == company and l["party"] == party and not l.get("revoked"):
                return tok
        if not create:
            return None
        tok = secrets.token_urlsafe(18)
        d["links"][tok] = {"company": company, "party": party, "created": time.time(), "opened": 0, "views": 0}
        _save(d)
        return tok


def revoke(token):
    with _lock:
        d = _load()
        if token in d["links"]:
            d["links"][token]["revoked"] = time.time()
            _save(d)
            return True
    return False


def find(token):
    """(company id, company name, party) for a live link, else None. Notes when it was opened."""
    if not token or len(token) > 64:
        return None
    with _lock:
        d = _load()
        l = d["links"].get(token)
        if not l or l.get("revoked"):
            return None
        if time.time() - l.get("opened", 0) > 60:
            l["opened"] = time.time()
            l["views"] = l.get("views", 0) + 1
            _save(d)
    co = next((c for c in store.companies() if c["name"] == l["company"]), None)
    if not co:
        return None
    return co["id"], co["name"], l["party"]


def listing():
    d = _load()
    out = [{"token": t, **l} for t, l in d["links"].items() if not l.get("revoked")]
    return {"base": d.get("base", ""), "links": sorted(out, key=lambda x: (x["company"], x["party"].lower()))}


def url(token, origin=""):
    b = base() or (origin or "").rstrip("/")
    return f"{b}/p/{token}" if b else f"/p/{token}"
