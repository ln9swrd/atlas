/** Compress replay summary into URL hash for share */

export function encodeSharePayload(obj) {
  try {
    const json = JSON.stringify(obj);
    return btoa(unescape(encodeURIComponent(json)))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
  } catch (_) {
    return '';
  }
}

export function decodeSharePayload(str) {
  try {
    const b64 = str.replace(/-/g, '+').replace(/_/g, '/');
    const json = decodeURIComponent(escape(atob(b64)));
    return JSON.parse(json);
  } catch (_) {
    return null;
  }
}

export function buildShareUrl(meta) {
  const payload = encodeSharePayload({
    s: meta.score,
    r: meta.rank,
    a: meta.acc,
    b: meta.boss || 'nemesis',
    t: Date.now(),
  });
  const base = location.href.split('#')[0];
  return `${base}#s=${payload}`;
}

export function readShareFromLocation() {
  const h = location.hash || '';
  const m = h.match(/#s=([A-Za-z0-9_-]+)/);
  if (!m) return null;
  return decodeSharePayload(m[1]);
}
