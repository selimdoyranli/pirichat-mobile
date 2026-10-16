# pirichat mobil

Bu branch (`pirichat`), Fluxer'ın Flutter istemcisinden pirichat uygulamasını çıkarıyor. Uygulama
açılışta doğrudan https://pirichat.online'a bağlanır; adı, ikonu ve rengi pirichat'ındır.

Repo: https://github.com/selimdoyranli/pirichat-mobile. Upstream:
https://github.com/fluxerapp/flutter_client, branch `canary`. Branch, sanalyer'in mobil fork'unun
(https://github.com/RadKod/sanalyer.com-mobile, branch `sanalyer`) üstüne kuruldu; onun markalama
işinin yerleri aynı, değerleri pirichat'ın.

## Ne değişti

- **Instance.** Varsayılan sunucu `pirichat.online` (API `https://pirichat.online/api`, gateway
  `wss://pirichat.online/gateway`), sunucunun `/.well-known/fluxer` belgesiyle aynı. Giriş
  ekranındaki instance seçici duruyor; varsayılana dönüş düğmesi pirichat'a döner.
- **Kimlikler.** Android `applicationId` ve iOS bundle id `online.pirichat.mobile` (masaüstü
  `online.pirichat.desktop`). iOS eklentileri `.ShareExtension`, `.NotificationService`,
  `.BroadcastExtension`; canary `online.pirichat.mobile.canary`. App group
  `group.online.pirichat.mobile`, Apple takımı `PL952Y4644`. Kotlin paketi `com.fluxer` kaldı.
- **Metinler.** 36 dil dosyasında ve Dart/Swift sabitlerinde kullanıcıya görünen ad küçük harfle
  `pirichat`. Türkçede ekler pirichat'a göre (pirichat'ı, pirichat'ın, pirichat'a).
- **Görseller.** Uygulama ikonları (Android adaptive + eski boy webp'ler, Play Store görseli, iOS
  Icon Composer katmanı), bildirim ikonu, uygulama içi sembol ve "pirichat" yazısı
  `tool/pirichat_brand_assets.py` ile `tool/brand/pirichat_logo.png`'den üretilir (masaüstündeki
  logonun aynısı). Logo potrace ile vektöre çevrilir; yazı açılış sayfasının fontu Radio Canada Big
  Bold (OFL). Alternatif ikon seçicisi kapalı (upstream'in ikonlarında Fluxer logosu var).
- **Renk.** Marka rengi logodaki kırmızı `#FD012D` (tema ailesi hsl 349, %99). Koyu temalarda
  tam bu renk (açıklık 50); açık temada açıklık 34, çünkü logo kırmızısı açık zeminde marka renkli
  metinde AA kontrastını tutturamıyor. İkon zemini logonun koyu karosu `#0A0A10`. Uygulama içi logo
  rozeti de (`FluxerBrandLogo`) varsayılan olarak koyu karo üstünde beyaz-kırmızı logo.
- **Linkler.** Koşullar `pirichat.online/kullanim-kosullari`, gizlilik `pirichat.online/gizlilik`,
  destek `selim.doyranli@albayrakmedya.com`, indirme `pirichat.online/indir`. Fluxer durum
  sayfası, Fluxer Labs ve geri bildirim girişleri kapalı. Uygulama linkleri (Android intent filter,
  iOS associated domains) `pirichat.online` yollarını dinliyor.
- **Push.** Relay adresi `push.pirichat.online`. Fluxer'ın relay'i bizim bundle id'mize bildirim
  teslim edemez. Relay kurulana kadar push gelmez.

## Nasıl derlenir

Flutter'ın güncel stable sürümü gerekiyor (pubspec `sdk: ^3.12.0`); Homebrew'daki Flutter
yetmiyor. Bu Mac'te ayrı kopya: `~/.cache/flutter-stable-pirichat`.

```sh
export PATH=~/.cache/flutter-stable-pirichat/bin:~/.cargo/bin:$PATH
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # *.g.dart repoda yok
flutter analyze
flutter test
```

Android'de flavor iki boyutlu: ortam (`stable`, `beta`, `canary`) ve push (`fcm`, `unifiedpush`).
Firebase dosyası olmadan `unifiedpush` ile derlenir:

```sh
dart tool/configure_build.dart --profile=oss && flutter pub get
flutter build apk --release --flavor stableUnifiedpush \
  --dart-define-from-file=tool/dart_defines/stable.json --dart-define=PUSH_PROVIDER=unifiedpush
```

iOS:

```sh
dart tool/configure_build.dart --profile=ios-store && flutter pub get
flutter build ios --no-codesign --flavor stable \
  --dart-define-from-file=tool/dart_defines/stable.json --dart-define=PUSH_PROVIDER=apns
```

`configure_build.dart` pubspec'i değiştirir; iş bitince `dart tool/restore_pubspec.dart`. Markdown
ayrıştırıcısı Rust'la derlenir: `rustup target add aarch64-apple-ios aarch64-apple-ios-sim
aarch64-linux-android armv7-linux-androideabi x86_64-linux-android`. iOS için CocoaPods 1.17 gerekir
(Xcode projesi `objectVersion = 70`).

Logo ya da renk değişirse:

```sh
python3 -m venv /tmp/v && /tmp/v/bin/pip install pillow fonttools brotli   # potrace: brew install potrace
/tmp/v/bin/python tool/pirichat_brand_assets.py
```

## iOS TestFlight

Lane `fastlane ios pirichat_testflight` (`fastlane/Fastfile`). App Store Connect API anahtarını
`~/.config/pirichat/asc.env` (ASC_KEY_ID, ASC_ISSUER_ID) ve `~/.config/pirichat/asc_key.p8`'den
okur; sertifika ve dört App Store profilini gerekirse üretir (`~/.config/pirichat/signing/`),
`aps-environment`'ı yalnız derleme süresince `production` yapar. Profil üretebilmesi için anahtarın
rolü Admin olmalı. App ID yeteneği değişirse bir kez `PIRICHAT_REFRESH_PROFILES=1` ile çalıştırılır.
Sürüm `PIRICHAT_VERSION` (varsayılan 1.0.0), build numarası `PIRICHAT_BUILD_NUMBER` (varsayılan
`YYYYMMDD.HHMM`).

```sh
export LANG=en_US.UTF-8
export PATH=~/.cache/flutter-stable-pirichat/bin:~/.cargo/bin:$PATH
dart tool/configure_build.dart --profile=ios-store && flutter pub get
dart run build_runner build --delete-conflicting-outputs
(cd ios && pod install)
APPLE_TEAM_ID=PL952Y4644 fastlane ios pirichat_testflight
```

Apple tarafında gerekenler (takım PL952Y4644): App Group `group.online.pirichat.mobile`; App ID'ler
`online.pirichat.mobile` (App Groups, Associated Domains, Communication Notifications, Push),
`.ShareExtension` ve `.BroadcastExtension` (App Groups), `.NotificationService` (App Groups,
Communication Notifications, Push); App Store Connect'te `online.pirichat.mobile` uygulama kaydı.

## Mağazaya çıkmak için kalanlar

1. **Push relay.** iOS ve FCM bildirimleri sunucudan Web Push olarak `push.pirichat.online`'daki
   relay'e gider (`fluxer-push --mode relay`), relay APNs'e/FCM'e iletir. sanalyer bunu
   RadKod/sanalyer.com `deploy/fluxer/push-relay.compose.yml` ile kuruyor; pirichat için aynısı,
   pirichat'ın APNs anahtarıyla kurulmalı.
2. **Android imzası ve Play.** `android/key.properties` (storeFile, storePassword, keyAlias,
   keyPassword) ve upload keystore'u, repoya girmeden. Play Console'da `online.pirichat.mobile`.
3. **Android push.** FCM flavor'ı için `online.pirichat.mobile` paketli Firebase projesi ve
   `google-services.json`; yoksa yalnız `unifiedpush` dağıtılır.
4. **Uygulama linkleri.** pirichat.online'da `/.well-known/assetlinks.json` (keystore SHA-256) ve
   `/.well-known/apple-app-site-association` (`PL952Y4644.online.pirichat.mobile`).
5. **Mağaza metinleri, ekran görüntüleri, gizlilik formu** Play Console ve App Store Connect'te.

## Bilerek bırakılanlar

- Paket adı `fluxer_app`, Kotlin paketi `com.fluxer`, `fluxer://` şeması, asset dosya adları
  (`fluxer-symbol.svg` gibi) ve sınıf adları upstream'le aynı; kullanıcı görmez, değiştirmek her
  merge'de çakışma çıkarır.
- Fluxer'a özgü beklenti taşıyan testler (fluxer.com host'ları, "Fluxer" metinleri, eski renk)
  upstream'deki gibi kaldı.
- Alan doğrulaması sunucuyla aynı adları kullanır: DNS `_pirichat.<alan>` ve
  `/.well-known/pirichat-verification` (upstream ve sanalyer `fluxer-verification` gönderiyor).

## Upstream senkron rutini

```sh
git fetch upstream canary && git fetch sanalyer
git checkout pirichat && git merge upstream/canary   # ya da sanalyer/sanalyer
git submodule update --init --recursive
flutter pub get && dart run build_runner build --delete-conflicting-outputs
git grep -niE "sanalyer|B5179E"     # marka taraması; yeni "Fluxer" metinleri de pirichat olmalı
flutter analyze && flutter test
```
