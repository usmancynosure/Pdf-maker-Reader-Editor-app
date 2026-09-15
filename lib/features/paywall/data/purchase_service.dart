import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A subscription/purchase plan shown on the paywall.
class ProPlan {
  const ProPlan(this.id, this.title, this.caption, this.price);
  final String id;
  final String title;
  final String caption;
  final String price;
}

/// Purchase gateway. This mock unlocks locally so the flow is testable now;
/// swap in RevenueCat by implementing these three methods with `purchases_flutter`:
///
///   await Purchases.configure(PurchasesConfiguration(apiKey));
///   final offerings = await Purchases.getOfferings();      // -> plans
///   final info = await Purchases.purchasePackage(package); // -> entitlement
///   final restored = await Purchases.restorePurchases();
///
/// The rest of the app only depends on this interface + the persisted `isPro`
/// flag in settings, so no UI changes are needed when going live.
abstract class PurchaseService {
  List<ProPlan> plans();
  Future<bool> purchase(ProPlan plan);
  Future<bool> restore();
}

class MockPurchaseService implements PurchaseService {
  const MockPurchaseService();

  @override
  List<ProPlan> plans() => const [
        ProPlan('lifetime', 'Lifetime', 'one-time', '\$79'),
        ProPlan('weekly', 'Weekly', '7-day trial', '\$4.99'),
        ProPlan('yearly', 'Yearly', 'best value', '\$39'),
      ];

  @override
  Future<bool> purchase(ProPlan plan) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return true; // pretend the purchase succeeded
  }

  @override
  Future<bool> restore() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return false; // nothing to restore in the mock
  }
}

final purchaseServiceProvider =
    Provider<PurchaseService>((_) => const MockPurchaseService());
