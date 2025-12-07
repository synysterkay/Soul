import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdConsentManager {
  static Future<void> showConsentForm() async {
    ConsentRequestParameters params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
          () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          ConsentForm.loadConsentForm(
                (ConsentForm consentForm) async {
              consentForm.show(
                    (FormError? formError) {
                  if (formError != null) {
                    loadAds();
                  }
                },
              );
            },
                (FormError formError) {
              loadAds();
            },
          );
        } else {
          loadAds();
        }
      },
          (FormError formError) {
        loadAds();
      },
    );
  }

  static void loadAds() {
    MobileAds.instance.initialize();
  }
}
