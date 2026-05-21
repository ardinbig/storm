/// The type of the authenticated principal.
enum AuthRole {
  /// Full system administrator - can manage agents, cards, and commissions.
  admin,

  /// Regular system-level user.
  user,

  /// Field agent - handles withdrawals, consumptions, and balance checks.
  agent,
}
