/* Service worker del sito "Posa segnavia Vermiglio".
   Serve a far funzionare il sito senza campo: la pagina, le tile della mappa e le foto
   restano in Cache Storage (non nella cache normale del browser, che il telefono svuota).

   Tre cache:
     guscio-<VER>  pagina, manifest, icone, libreria Leaflet
     tile          tile della mappa (le nostre in tiles/, quelle di OpenTopoMap e di Esri)
     foto          foto dei pali

   La pagina chiede il pacchetto completo con postMessage({cmd:"scarica", urls:[...]}).
*/
const VER = "2026-10-07";
const GUSCIO = "guscio-" + VER, TILE = "tile", FOTO = "foto";

const BASE = new URL("./", self.location).pathname;          // .../segnaletica-sentieri/
const SHELL = [BASE, BASE + "index.html", BASE + "manifest.webmanifest",
               BASE + "icona-192.png", BASE + "icona-512.png",
               BASE + "lib/leaflet.js",
               "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.js"];

self.addEventListener("install", e => {
  e.waitUntil((async () => {
    const c = await caches.open(GUSCIO);
    await Promise.all(SHELL.map(u => c.add(new Request(u, {cache: "reload"})).catch(() => {})));
    self.skipWaiting();
  })());
});

self.addEventListener("activate", e => {
  e.waitUntil((async () => {
    for (const k of await caches.keys()) {
      if (k.startsWith("guscio-") && k !== GUSCIO) await caches.delete(k);
    }
    await self.clients.claim();
  })());
});

/* ---------- a quale cache appartiene una richiesta ---------- */
function dove(url){
  const u = new URL(url, self.location.href);     // accetta anche "tiles/13/…" dalla pagina
  if (u.pathname.includes("/tiles/") || /tile\.opentopomap\.org|arcgisonline\.com/.test(u.hostname)) return TILE;
  if (u.pathname.includes("/foto/")) return FOTO;
  if (u.hostname === "cdnjs.cloudflare.com") return GUSCIO;
  if (u.pathname.includes("/lib/") || u.pathname.endsWith("manifest.webmanifest")
      || /icona-\d+\.png$/.test(u.pathname)) return GUSCIO;
  return null;
}

async function primaLaCache(req, nome){
  const c = await caches.open(nome);
  const hit = await c.match(req, {ignoreVary: true});
  if (hit) return hit;
  const r = await fetch(req);
  if (r && r.ok) c.put(req, r.clone());
  return r;
}

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;

  if (req.mode === "navigate") {                       // la pagina: prima la rete, poi la copia
    e.respondWith((async () => {
      try {
        const r = await fetch(req);
        if (r && r.ok) (await caches.open(GUSCIO)).put(BASE + "index.html", r.clone());
        return r;
      } catch (err) {
        return (await caches.match(BASE + "index.html")) || (await caches.match(BASE)) || Response.error();
      }
    })());
    return;
  }

  const nome = dove(req.url);
  if (!nome) return;
  e.respondWith(primaLaCache(req, nome).catch(() => new Response("", {status: 504})));
});

/* ---------- scarico del pacchetto, guidato dalla pagina ---------- */
let inCorso = false;

async function avvisa(msg){
  for (const c of await self.clients.matchAll()) c.postMessage(msg);
}

async function scarica(urls){
  if (inCorso) return;
  inCorso = true;
  const code = {}, lista = [];
  for (const u of urls) {
    const nome = dove(u) || GUSCIO;
    code[nome] = code[nome] || await caches.open(nome);
    lista.push([u, nome]);
  }
  let fatte = 0, saltate = 0, errori = 0, byte = 0;
  const totale = lista.length;
  const PARALLELE = 6;
  let i = 0;
  async function operaio(){
    while (i < lista.length) {
      const [u, nome] = lista[i++];
      const c = code[nome];
      try {
        if (await c.match(u, {ignoreVary: true})) { saltate++; }
        else {
          const r = await fetch(u, {cache: "no-store"});
          if (r && r.ok) {
            const b = r.clone();
            await c.put(u, r);
            byte += (await b.blob()).size;
          } else errori++;
        }
      } catch (err) { errori++; }
      fatte++;
      if (fatte % 15 === 0 || fatte === totale) await avvisa({tipo: "avanzamento", fatte, totale, errori, byte, saltate});
    }
  }
  await Promise.all(Array.from({length: PARALLELE}, operaio));
  inCorso = false;
  await avvisa({tipo: "finito", fatte, totale, errori, byte, saltate});
}

async function stato(){
  const out = {};
  for (const nome of [GUSCIO, TILE, FOTO]) {
    const c = await caches.open(nome);
    out[nome === GUSCIO ? "guscio" : nome] = (await c.keys()).length;
  }
  if (navigator.storage && navigator.storage.estimate) {
    const s = await navigator.storage.estimate();
    out.byte = s.usage || 0;
  }
  return out;
}

self.addEventListener("message", e => {
  const d = e.data || {};
  if (d.cmd === "scarica") e.waitUntil(scarica(d.urls || []));
  else if (d.cmd === "stato") e.waitUntil(stato().then(s => avvisa({tipo: "stato", ...s})));
  else if (d.cmd === "svuota") e.waitUntil((async () => {
    await caches.delete(TILE); await caches.delete(FOTO);
    await avvisa({tipo: "stato", ...(await stato())});
  })());
});
