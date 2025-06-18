'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "63f9fae8f80930ae6f7454c9ff61f07f",
"assets/AssetManifest.bin.json": "f1c9beb22536b76e1a5ff988693811a0",
"assets/AssetManifest.json": "774bb4097abc5770fad955c3e1096fc3",
"assets/assets/images/backgrounds/main_background.png": "3cf902d84bef5dd6b2df64c72818b64a",
"assets/assets/images/comic_game/image1.png": "7ff3d282135a30578ec60ac3396b1f04",
"assets/assets/images/comic_game/image1_sin_bocadillo.png": "4ac7c5f9139073a2f44ee1939b3af163",
"assets/assets/images/comic_game/image1_sin_texto.png": "29fef56d38892138c53626c8e66bf075",
"assets/assets/images/comic_game/image2.png": "d2528759b18f48bf788f1c371e2e0d48",
"assets/assets/images/comic_game/image2_sin_bocadillo.png": "11d377695a9b246e67482ff425e9542c",
"assets/assets/images/comic_game/image2_sin_texto.png": "f785810b33209632c69afca3fc5acfb0",
"assets/assets/images/comic_game/image3.png": "34a738d546bb89baabfdb586a33348c4",
"assets/assets/images/comic_game/image3_sin_bocadillo.png": "d9979bd11301a86a046b76625a4d4367",
"assets/assets/images/comic_game/image3_sin_texto.png": "a1c9e55f4419707c859771c2790aec5e",
"assets/assets/images/comic_game/image4.png": "daf8bbc789dd7b7a18a54e279bba0175",
"assets/assets/images/comic_game/image4_sin_bocadillo.png": "447ee006af7dde9aa09a8d8f1dac9851",
"assets/assets/images/comic_game/image4_sin_texto.png": "e7a804c0f87a5e891d180c8e5fd54860",
"assets/assets/images/comic_game/image5.png": "ecddbef1f666dc7314b6dbeb7e721b60",
"assets/assets/images/comic_game/image5_sin_bocadillo.png": "bd767c1ae568d132ca56b6f21ce47c25",
"assets/assets/images/comic_game/image5_sin_texto.png": "45299fa4b2f1b0e0afc4b1b195e8031b",
"assets/assets/images/icons/achievements_icon.png": "9af82e860017e25e1c7dbbb583078ae3",
"assets/assets/images/icons/logout_icon.png": "e4dd008b582901126a8dfed666402387",
"assets/assets/images/icons/play_icon.png": "e5e1549e7089880e72c0cd400a144f57",
"assets/assets/images/icons/profile_icon.png": "a0953753c428c2a44140017a3cf911ae",
"assets/assets/images/icons/reading_icon.png": "f2a84e6adb5cc050c8f8bb6b288b14fc",
"assets/assets/images/icons/scores_icon.png": "200955ec2a02504637f19d48c494f82e",
"assets/assets/images/icons/store_icon.png": "5270f31d0fcf32207402136bd5fc12f4",
"assets/assets/images/logo/playmobil_logo.png": "22ff9791e2e6aa5987e535f4890b6757",
"assets/assets/images/memory_game/belt.png": "24de32fac52795ab59ccc816b1ee726c",
"assets/assets/images/memory_game/blouse.png": "9236c7d1c31ae4f11b6ed2d504a8877e",
"assets/assets/images/memory_game/bracelet.png": "6f92d4a5be22594bd05e5ea0013204e6",
"assets/assets/images/memory_game/dress.png": "b80580cc8e515fcdb6fe01390170b504",
"assets/assets/images/memory_game/gloves.png": "2fbe8d95fee61fa9bf33a21a39481b61",
"assets/assets/images/memory_game/hat.png": "2dcd88052ed17e2a47a20550a51ae467",
"assets/assets/images/memory_game/jeans.png": "b94a1c354e9a8793ce0ad218cc50c8a5",
"assets/assets/images/memory_game/jumper.png": "c893280b81a20b5882ba35cf883799f6",
"assets/assets/images/memory_game/necklace.png": "36b9e2052e46e9832a11f58fb3dd99a0",
"assets/assets/images/memory_game/raincoat.png": "cda56e84b808c19e5d3937dd95c99406",
"assets/assets/images/memory_game/ring.png": "eb9f124b51421909f1b09f4ac796141a",
"assets/assets/images/memory_game/scarf.png": "728be87c9024f9b227c11fb4c0db05c6",
"assets/assets/images/memory_game/shirt.png": "76d60b3792e6d243d86229d2d0d73360",
"assets/assets/images/memory_game/shoes.png": "7bc2688e459752287b743bee87ce5075",
"assets/assets/images/memory_game/skirt.png": "8f3439d27419b638c90be0d4cf930c42",
"assets/assets/images/memory_game/slippers.png": "c5bc66c3aef0d0bd8e7be963ac04cf1c",
"assets/assets/images/memory_game/sunglasses.png": "1ecb84549fadc14c8342f9e33e3b819e",
"assets/assets/images/memory_game/texto_belt.png": "d83140d20527aaca7c384b23f961819b",
"assets/assets/images/memory_game/texto_blouse.png": "a45d06be77cccd6ce566187170d13cc6",
"assets/assets/images/memory_game/texto_bracelet.png": "829fe4ac2c19248550263c0bd3c1dd38",
"assets/assets/images/memory_game/texto_dress.png": "42abeb13022ccab1031236586ae53502",
"assets/assets/images/memory_game/texto_gloves.png": "fece5ae3658c30b6dec3ef6bc5ad2a89",
"assets/assets/images/memory_game/texto_hat.png": "79cb8c35b895b91cb1de21c6015b0c76",
"assets/assets/images/memory_game/texto_jeans.png": "15ae9f57d4bd03a0a1a73b763e6386d1",
"assets/assets/images/memory_game/texto_jumper.png": "ea8e7b4891e4dc5baab899af1949b3cc",
"assets/assets/images/memory_game/texto_necklace.png": "d4e7a9b2770806a0e9cd48363a03ef8c",
"assets/assets/images/memory_game/texto_raincoat.png": "608c72283edcf7116a3b518c1a45384e",
"assets/assets/images/memory_game/texto_ring.png": "c70358bf97891faf61bc6d67aa310b84",
"assets/assets/images/memory_game/texto_scarf.png": "942dc2d686fbbb0dbacad445625e14a9",
"assets/assets/images/memory_game/texto_shirt.png": "db632b41b1772692af1a34abdf044363",
"assets/assets/images/memory_game/texto_shoes.png": "7bbafbdb0801e971c57f9f54dfb224c7",
"assets/assets/images/memory_game/texto_skirt.png": "749cae0ceaf2b6d6e00a7f9ab7ef8de5",
"assets/assets/images/memory_game/texto_slippers.png": "9332829f8097e46637736f750b893eb4",
"assets/assets/images/memory_game/texto_sunglasses.png": "f4fb18a068210ecc88dc6100bdfd4f68",
"assets/assets/images/memory_game/texto_trainers.png": "4f93c938b11278cc081dd34190acdb36",
"assets/assets/images/memory_game/trainers.png": "359f4d0536f622c39666321c7fa96509",
"assets/assets/images/playmobil_comic_fondo.png": "af9aa03f540c830f9e0e1103907d4ae2",
"assets/assets/images/playmobil_juegos_fondo.png": "267ab203f70fc6b0f264e4715d1727a7",
"assets/assets/images/playmobil_logros_fondo.png": "7135a09bfe05f058e02de2f27ec63d72",
"assets/assets/images/playmobil_perfil_fondo.png": "cd17c8592b77281e6625abad73f87d70",
"assets/assets/images/playmobil_salon_fama_fondo.png": "1ebc8534db93dee845b83160e936a8d0",
"assets/assets/images/playmobil_tienda_fondo.png": "deb0d113bad29a8b10b36df7e8ca31db",
"assets/assets/images/puzzle/puzzle1.png": "c80703fe75552f36367926ef0972db72",
"assets/assets/images/puzzle/puzzle2.png": "397edbc4d5e491754bdfa4d7031b21fb",
"assets/assets/images/store/ball_necklace.png": "80083fb8e0eec09f23156a20442de139",
"assets/assets/images/store/black_belt.png": "972abb10754b8fbd6606cf0a4a6ceda6",
"assets/assets/images/store/black_boots.png": "d174a7de05435644d8444c20b591aa96",
"assets/assets/images/store/blue_crystal_dress.png": "a63be1c0e7013b471028f1ab335eca4d",
"assets/assets/images/store/blue_hat.png": "b2f02a2990a39d4157d73354b660ac96",
"assets/assets/images/store/blue_jacket.png": "90f826409d0a6695e0c874a9b8c85937",
"assets/assets/images/store/blue_ring.png": "480f2c3171fffa65970f4f8f6550fe31",
"assets/assets/images/store/blue_yellow_short_skirt.png": "745a65124bfb49a5ba7717702390b8f1",
"assets/assets/images/store/brown_pants.png": "739ddb36b4d61d5988c9549f9a45ebcd",
"assets/assets/images/store/flower_necklace.png": "220654decb689f970d35192c61a3331c",
"assets/assets/images/store/green_bag.png": "a27bde90a3a8227af8be1c92cfe75712",
"assets/assets/images/store/green_belt.png": "181af1aac52f8b9ec6a13324750e585a",
"assets/assets/images/store/green_blouse.png": "675747d3f7a8d13dc382878b20499d88",
"assets/assets/images/store/green_pants.png": "02739c135c55626ddfa1070bea9f6b74",
"assets/assets/images/store/green_red_dress.png": "ab2ac7ec80a01d86afb96b26c6eafb6f",
"assets/assets/images/store/jeans.png": "68d4498a408e89b52e08c4b0e56cea57",
"assets/assets/images/store/light_blue_hat.png": "7fd0e105d8dfee062a8cf6d2999e2bac",
"assets/assets/images/store/lilac_skirt.png": "3352fa71a2e3120193e655d6f86e3236",
"assets/assets/images/store/lilac_vest.png": "cc8d36f0c8891f6dcd4c11f1453f09db",
"assets/assets/images/store/loklo.png": "87bd43e97af83e9318fccd8c17c51277",
"assets/assets/images/store/long_black_hair.png": "841365c369a9ea7ea2be48a8c87abf28",
"assets/assets/images/store/long_blonde_hair.png": "e43b4d68136df3bbbadbafab2f030e24",
"assets/assets/images/store/long_brown_hair.png": "5de3038e7af10edcaa48819a69a11596",
"assets/assets/images/store/maroon_vest.png": "48170dd5d5d4184bbe1c9e3af129e7c4",
"assets/assets/images/store/pink_bag.png": "0db2b3e77444d1b48b7c0b2e0fe44c72",
"assets/assets/images/store/pink_golden_dress.png": "63f5e37601c2f7f82e0dd3aec544f823",
"assets/assets/images/store/pink_sandals.png": "0b16fb6eb32979c963e203d4df95d773",
"assets/assets/images/store/pink_shoes.png": "dea1a7f3660cbc5c6bc398753e00e8c7",
"assets/assets/images/store/purple_blouse.png": "6857d40f791e445e82eca70960c9dc91",
"assets/assets/images/store/purple_ring.png": "8b17ae04da353d4ad1d8c9d5c70dc6fd",
"assets/assets/images/store/red_skirt.png": "5b7aa0e0881ff138f6750f0f8e2bbb55",
"assets/assets/images/store/short_black_hair.png": "fcfeacc20cae726b51fc577257e0a6f6",
"assets/assets/images/store/short_blonde_hair.png": "37bc2c6de98cce8405a2c23558af0b74",
"assets/assets/images/store/short_brown_hair.png": "e9e1cdd6aee6ca45080467437009fcaf",
"assets/assets/images/store/silver_belt.png": "892fb177c44492ff7cd5e055d86bec3c",
"assets/assets/images/store/star_necklace.png": "c310bafb7edc14391242ecfa769e35ac",
"assets/assets/images/store/trainers.png": "1263b38d06e2608b26f68c148af584df",
"assets/assets/images/store/white_hat.png": "cd6b444764de0713603345ea8413033a",
"assets/assets/images/store/white_pants.png": "ba89654a687330db15123e416f85d1d4",
"assets/assets/images/store/yellow_bag.png": "924672f8693c8777ccf1c54eccb23ce0",
"assets/assets/images/store/yellow_belt.png": "0cd47ee8b8358050e1bc4f69d8db9f9b",
"assets/assets/images/store/yellow_ring.png": "ea4600b64b711ac9510c4bebfe343a4c",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "84a7683dc1ac7f352ea26de42fbf131b",
"assets/NOTICES": "958a4212102aedcfc83772d085882c66",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "35e0e485bf728de70babdaf2c6784f38",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "9dc33ad55e45b3d8025489b57f5ed904",
"/": "9dc33ad55e45b3d8025489b57f5ed904",
"main.dart.js": "3aaa53891b3a225e733c15d00460bc7c",
"manifest.json": "a53233efd06c0ad2b07952ecf4ac3c4b",
"version.json": "11d9d2abc255056818d062db88d7ff26"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
