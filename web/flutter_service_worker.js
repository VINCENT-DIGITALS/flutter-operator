const CACHE_NAME = 'map-tile-cache-v1';
const CACHE_URLS = [
  'https://tile.openstreetmap.org/{z}/{x}/{y}.pn', // Standard map tiles
  'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png' // Grayscale map tiles
];

// Install the service worker and add caching for map tiles
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(CACHE_URLS);
    })
  );
});

// Intercept fetch requests and cache map tiles
self.addEventListener('fetch', event => {
  const requestUrl = new URL(event.request.url);

  // Check if the request is for a map tile URL
  if (CACHE_URLS.some(url => event.request.url.startsWith(url))) {
    event.respondWith(
      caches.match(event.request).then(cachedResponse => {
        // Return cached response if available, or fetch and cache if not
        return (
          cachedResponse ||
          fetch(event.request).then(response => {
            return caches.open(CACHE_NAME).then(cache => {
              cache.put(event.request, response.clone());
              return response;
            });
          })
        );
      })
    );
  }
});
