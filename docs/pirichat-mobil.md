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
APPLE_TEAM_ID=PL952Y4644 FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=180 fastlane ios pirichat_testflight
```

İmza kimliği (Apple Distribution QC4RFX8YB4) ayrı bir anahtar zincirinde durur:
`~/Library/Keychains/pirichat-signing.keychain-db`, şifresi `~/.config/pirichat/signing/keychain.pw`.
Arama listesinde login'den önce gelir, codesign şifre sormaz. Bu Mac'teki Xcode 26.3'te iOS 26.4 VoIP
delegate'i derlenmez; `VoipRegistry.swift` onu `#if compiler(>=6.3)` ile ayırır.

Apple tarafında gerekenler (takım PL952Y4644): App Group `group.online.pirichat.mobile`; App ID'ler
`online.pirichat.mobile` (App Groups, Associated Domains, Communication Notifications, Push),
`.ShareExtension` ve `.BroadcastExtension` (App Groups), `.NotificationService` (App Groups,
Communication Notifications, Push); App Store Connect'te `online.pirichat.mobile` uygulama kaydı.

## Durum (2026-10-18)

- **iOS:** TestFlight'ta 1.0.0 (20261018.1724, sanalyer merge'ü: sınırlı fotoğraf erişimi, topluluk önizleme menüsü), iç test grubu "pirichat ekibi" (selimdoyranli@gmail.com).
  App Store Connect'te uygulama `pirichat` (Apple ID 6823670202): Türkçe açıklama, anahtar kelimeler,
  altyazı, gizlilik bağlantısı, iPhone 6.9" ve iPad 13" ekran görüntüleri yüklü. İncelemeye
  gönderilmedi.
- **Android:** Play Console'da `pirichat` (online.pirichat.mobile). Dahili test ve kapalı test (Alpha)
  kanallarında 1.0.0 (3) yayında; ilk inceleme geçti, yeni sürümler artık taslak değil doğrudan
  yayına alınabiliyor. Test listesi
  "pirichat kapali test". Mağaza girişi Türkçe, kategori Haberleşme, tüm uygulama içeriği
  beyanları dolu. Ön plan hizmeti beyanının videosu `docs/media/pirichat-arka-plan-hizmetleri.mp4`.
  Play App Signing açık; upload anahtarı `~/.config/pirichat/android/upload.jks`.
- **Push:** relay container'ı yok. `FLUXER_PUSH_SERVICE_OWN_RELAY_HOSTS=push.pirichat.online` olduğu
  için ana push servisi `push.pirichat.online/relay/v1/...` adreslerini kendi içinde APNs'e (anahtar
  3YRXA9BX48, sandbox+production, takım geneli) ve FCM'e (Firebase projesi `pirichat-mobile`, servis
  hesabı `pirichat-push`) gönderir. Değerler Coolify env'lerinde. Android'de uçtan uca denendi.
- **Uygulama linkleri:** pirichat.online `apple-app-site-association` ve `assetlinks.json`
  (`fluxer_app_proxy`) pirichat kimliklerini veriyor.
- **İnceleme hesabı:** `pirichatinceleme` (şifre `~/.config/pirichat/review_account.txt`), demo
  topluluğu "pirichat Ekibi". İkinci hesap `pirichattest2` bildirim testi için.

## Play'e yükleme

Android paketi FCM'li flavor'la derlenir; versionCode her yüklemede bir artmalı:

```sh
dart tool/configure_build.dart --profile=android-fcm && flutter pub get
flutter build appbundle --release --flavor stableFcm --dart-define-from-file=tool/dart_defines/stable.json \
  --dart-define=PUSH_PROVIDER=fcm --build-name=1.0.0 --build-number=<n>
```

Yükleme `~/.config/pirichat/play-service-account.json` ile androidpublisher v3 API'si üzerinden:
edit aç, `upload_edit_bundle`, `internal` ve `alpha` track'lerine `completed` sürüm yaz, commit.
fastlane'in gem'leri (`google-apis-androidpublisher_v3`, `googleauth`) Homebrew Ruby'siyle
(`/opt/homebrew/opt/ruby/bin/ruby`, `GEM_HOME=~/.gem/ruby/4.0.0`) kullanılabiliyor; sistem Ruby'si
(2.6) yüklemiyor. 277 MB'lık aab için istemci zaman aşımı `client_options.read_timeout_sec`
(`request_options`'ta yok) uzatılmalı. Derleme bitince `git checkout -- pubspec.yaml
lib/features/settings/services/premium_store_purchase_client.dart` (restore_pubspec oss
profiline çevirir, repodaki hâl o değil).

## Mağaza görselleri

`integration_test/flows/store_screenshots_test.dart` + `tool/store_screenshots.sh <simülatör-udid>
<klasör>` inceleme hesabıyla demo topluluğu gezer ve her ekranı simctl ile kaydeder
(TEST_LAB_EMAIL, TEST_LAB_PASSWORD, TEST_LAB_GUILD_ID env'den). Bildirim izni kanalları testte
taklit edilir, simülatör ilk çalıştırmada `xcrun simctl erase` ile temiz olmalı.

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
