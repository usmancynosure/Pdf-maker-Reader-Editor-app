/// Paths to bundled image assets (generated via tools/generate_images.py).
class AppImages {
  AppImages._();

  static const _base = 'assets/images';

  static const logo = '$_base/logo.png';
  static const wordmark = '$_base/wordmark.png';
  static const proPlanet = '$_base/pro_planet.png';
  static const proCrown = '$_base/pro_crown.png';
  static const success = '$_base/success.png';
  static const processing = '$_base/processing.png';
  static const scanOnboarding = '$_base/scan_onboarding.png';

  // Empty states
  static const emptyDocuments = '$_base/empty_documents.png';
  static const emptySearch = '$_base/empty_search.png';
  static const emptyPdf = '$_base/empty_pdf.png';
  static const emptyFolder = '$_base/empty_folder.png';
}
