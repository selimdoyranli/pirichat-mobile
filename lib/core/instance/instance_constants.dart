// pirichat: the app is locked to https://pirichat.online by default. The upstream
// "official" Fluxer hosts are gone from this list, so fluxer.com is treated
// like any other self-hosted instance (discovered through its well-known).
abstract final class InstanceConstants {
  static const int apiCodeVersion = 1;
  // Matches what pirichat.online/.well-known/fluxer resolves to (api_client).
  static const String defaultApiBaseUrl = 'https://pirichat.online/api';
  static const String defaultGatewayUrl = 'wss://pirichat.online/gateway';
  static const String defaultInstanceInputUrl = 'pirichat.online';
  // pirichat has no canary instance; canary builds use the same server.
  static const String canaryApiBaseUrl = defaultApiBaseUrl;
  static const String canaryInstanceInputUrl = defaultInstanceInputUrl;
  static const String defaultMarketingBaseUrl = 'https://pirichat.online';
  static const String defaultProductName = 'pirichat';
  static const String defaultPremiumProductName = 'Premium';
  static const int maxRecentInstances = 5;

  static const Set<String> officialInstanceHosts = <String>{
    'pirichat.online',
    'www.pirichat.online',
  };
}
