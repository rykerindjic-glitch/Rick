const CACHE="pl-2026-07-07-v3.34";
const ASSETS=["./","./index.html","./config.js","./manifest.json"];
self.addEventListener("install", e=>{ e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS).catch(()=>{}))); self.skipWaiting(); });
self.addEventListener("activate", e=>{ e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k))))); self.clients.claim(); });
self.addEventListener("fetch", e=>{
  if(e.request.url.includes("supabase.co")) return;        // always live data
  e.respondWith(
    fetch(e.request).then(res=>{ const cp=res.clone(); caches.open(CACHE).then(c=>c.put(e.request,cp)).catch(()=>{}); return res; })
    .catch(()=> caches.match(e.request).then(r=> r || caches.match("./index.html")))
  );
});
