enum SubscriptionPlan { none, oneMonth, threeMonth, sixMonth, oneYear }

class AppUser {
  final String id;
  final String phoneNumber;
  final String? displayName;
  final bool isPhoneVerified;
  final SubscriptionPlan plan;
  final DateTime? subscriptionExpiresAt;

  const AppUser({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    this.isPhoneVerified = false,
    this.plan = SubscriptionPlan.none,
    this.subscriptionExpiresAt,
  });

  bool get isPremium =>
      plan != SubscriptionPlan.none &&
      (subscriptionExpiresAt?.isAfter(DateTime.now()) ?? false);

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        phoneNumber: json['phoneNumber'] as String,
        displayName: json['displayName'] as String?,
        isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
        plan: SubscriptionPlan.values.firstWhere(
          (p) => p.name == json['plan'],
          orElse: () => SubscriptionPlan.none,
        ),
        subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
            ? DateTime.parse(json['subscriptionExpiresAt'] as String)
            : null,
      );
}
