'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "35ffc79c1da7358206f182942b324d35",
".git/config": "e29dc1470705b9453ad08e913225e311",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "149a28e5228c44a132e4f9b7bb0aade7",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "46948442e5051734ed6657c77d89c412",
".git/logs/refs/heads/gh-pages": "46948442e5051734ed6657c77d89c412",
".git/logs/refs/remotes/origin/gh-pages": "1b6078d34ca0b9d846c2c35eb0eee98c",
".git/objects/00/b28bf0af76364e24523d5835133a828b947c5d": "5b2b68c3990728814f99d50c9dcf683f",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/0a/20ae21df81f97cdd4d032084f27764eff8aa7b": "0fa83a19d32bf4ed8d11efa88a62873b",
".git/objects/11/c85f7e3dda36b86b8f3f94867e7da44b61d47c": "666eb7d0a90f6d12e44661eb64c7a712",
".git/objects/30/9a62de538174cefe05c539726bc65291d84270": "7a0be3178bb00ddf31db36fb57470e35",
".git/objects/36/5c14fb8f7c2ce852620e96644e3160246d6bc3": "40c1c515504be4127b0a219cfc83398d",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/3c/683c7d0a88cad9a82db07ebbc19a2271440bfe": "76c24cd161806844a51e99aba3edde54",
".git/objects/3d/fd3f2f61b3f8ce6ec154fc52c225bc073d3b6a": "28784d83d116a815a0791373f19ef3f7",
".git/objects/48/3e87c1c76ef89eaa812efe99727971f56f41ca": "fff158e8dd7e8aa535dd9bb1b1ff9414",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/55/c260ced10ef61535a1672f503987c5ef0e0a91": "2063a164da1653af2e3cd9d1d17f507c",
".git/objects/5d/199094a17ad6986c55b86fd22d57bf3aa58499": "5ce2ccfc7e9742d84aa0fa062c8c24f2",
".git/objects/65/3d46dc60bf9044628f35df65fc5f19f37076c8": "9b40ef209a822d1ca7a9de904d34b6d1",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/6b/08911c2d8c26c4487e367b6dae2c208082fa39": "66f25cfde1bdca831a09b98664e6dcb4",
".git/objects/6c/b76ada582d9485a43db63ec3d3592501e8d6de": "8d73095a881580a9ef6c22944a5d4616",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/79/f644607aa43b1870f466c1394a3c318be62c0e": "7bf79bd1445108791953e187ea9ab807",
".git/objects/7b/d710bc64c6480992237f031a9a22ef0e62a0b4": "e42266220234a0951442031b26b70824",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/83/249198111fb9d6feaa19a7ee12e7e6681a12b8": "21b7183f352efc8e2c4c437ce73c6a8e",
".git/objects/83/eb161620b19f1f6de2bf95be128058355be2a1": "40378cd0a2069ca9cee1d961aba26690",
".git/objects/84/34b4bc4ba61059dfb067adf026a390c6991254": "43bc07dd96a35fcfcd2870dacb96ef56",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/objects/86/48e057a6540c9d6fc0a7fff22c37a38b37b1de": "b1ea0e6eae7654048c4a04172cc83b8d",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8a/cda3b814f71435954016af9b350026b54b4f32": "3fba918ee010ad68f1d14a84d1515a29",
".git/objects/8e/21753cdb204192a414b235db41da6a8446c8b4": "1e467e19cabb5d3d38b8fe200c37479e",
".git/objects/8f/2ce0bbc410e2b2cb52567ec19af557fcaea209": "d688a816d0a63233cf110d979c2f05a1",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/96/1113876b929ab5af49563fc2a7c98a29a7ee3d": "ece80c990d9d9fdfb76bedd846ea6f76",
".git/objects/97/0b7c86ae2a04ad48fd5b99a22485daf91fd4a6": "1eb3172e7d11ae6912af40516f39ce9f",
".git/objects/9c/01bc3eea782c949136e92ecfa4a4cf378ee575": "652481634c3f21317aecaefdb28cda8f",
".git/objects/9c/1aad5e9250a2e1e8b76942a72568a0e0f5eb35": "d78d60832d2a5582ba59de23cc539bc1",
".git/objects/a6/ade862332d2d3f52faa895ad8a3f0dd33f7e80": "84ac282a1f15340f2881f0311c3df2fb",
".git/objects/a7/3f4b23dde68ce5a05ce4c658ccd690c7f707ec": "ee275830276a88bac752feff80ed6470",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/ae/d87c6702af48f059b18353682372ccdfd1fe8c": "43ba0fd2d4e1a69b161ed42a15a7fb6a",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b8/ee8d6e9390dfe77e1abec0a2a79891a4ab8ebe": "02f551484622cd25b08601219272b56d",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/d3/3fe3c6a471bfe394b30ece3f1725021c3bd1e4": "25b614f7f03a11426af3709b9b119258",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/f5845286c38099759ea32a6857411818c0792f": "5abf8d0535605f2cf11a9d61c925e4a3",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/db/629475f955a12a3496a4a914c438d2d227c3a3": "843853c63090ca587c248840b76778eb",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ed/baca433712b5ba3679ef9e235e1d3173ab2aa4": "f6ccd7cfa47786c7fef1341e40d271a2",
".git/objects/f0/165cde6d75a486375fd6cf39a1ad76dfdd2a9a": "4ecb323d93309b3ed4f97860109847f5",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/objects/fe/302a630e0ee4235539d92b928d09b540ab7ea5": "5c9f7d55aca59d7f3163c1ef42e90831",
".git/refs/heads/gh-pages": "791dfd951ce5bc389e9971867280e239",
".git/refs/remotes/origin/gh-pages": "791dfd951ce5bc389e9971867280e239",
"assets/AssetManifest.bin": "16232a297caf85aa633bc173f6de422c",
"assets/AssetManifest.bin.json": "6407ad85ccf3e99fbb1317bb1fb152bd",
"assets/FontManifest.json": "65f94acffb0ac2ee75d87cb32190e494",
"assets/fonts/MaterialIcons-Regular.otf": "5ac5e6eff11cc7cf04bc502ef3dda879",
"assets/NOTICES": "74869a6f8e70892b7bbc990f3d4fc605",
"assets/packages/lucide_icons/assets/lucide.ttf": "f9ba0b4172a0beabfecd5857b55dfe72",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "19bd3b45be7f896dcde7efd7eb3f476f",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "6b6dc1ab93b799fe4c4b6da31cfb495b",
"/": "6b6dc1ab93b799fe4c4b6da31cfb495b",
"main.dart.js": "860d4d2e00e8a76414fef807a89493e2",
"manifest.json": "bc13733d8e5e5f17c729d88e49616b46",
"version.json": "2c81c9d6311d4cbde3cb5b16f9d13565"};
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
