/// Shared email validation used across auth forms.
bool isValidEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return false;

  // Allow demo/local domains (e.g. annotator@demo.local) and longer TLDs.
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  if (!isValidEmail(value)) {
    return 'Invalid email format';
  }
  return null;
}
