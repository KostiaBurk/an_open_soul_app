enum UserPlan {
  echo,
  pulse,
  novaLink,
}

extension UserPlanExtension on UserPlan {
  String get name {
    switch (this) {
      case UserPlan.echo:
        return 'Echo';
      case UserPlan.pulse:
        return 'Pulse';
      case UserPlan.novaLink:
        return 'NovaLink';
    }
  }

  String get emoji {
    switch (this) {
      case UserPlan.echo:
        return '🖤';
      case UserPlan.pulse:
        return '🩶';
      case UserPlan.novaLink:
        return '🔮';
    }
  }

  static UserPlan fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pulse':
        return UserPlan.pulse;
      case 'novalink':
        return UserPlan.novaLink;
      default:
        return UserPlan.echo;
    }
  }

  String get firestoreValue => name.toLowerCase();
}
