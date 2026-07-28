import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/branding_engine.dart';

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'ADMIN' or 'MEMBER'
  final String department;
  final String branch;
  final String tenantId;
  final String? accessToken;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.department,
    required this.branch,
    required this.tenantId,
    this.accessToken,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'role': role,
    'department': department,
    'branch': branch,
    'tenantId': tenantId,
    'accessToken': accessToken,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? 'usr_000',
    email: json['email'] ?? '',
    fullName: json['fullName'] ?? 'Unnamed Safety Member',
    role: (json['role'] ?? 'MEMBER').toString().toUpperCase(),
    department: json['department'] ?? 'Field Division',
    branch: json['branch'] ?? 'Main Facility',
    tenantId: json['tenantId'] ?? 'petroapex',
    accessToken: json['accessToken'],
  );
}

class AuthProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  BrandingProvider? _brandingProvider;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool get isAdmin => _currentUser?.role.toUpperCase() == 'ADMIN';
  
  String get roleBadgeText => isAdmin ? '★ مسؤول عام (ADMIN)' : '🛡️ عضو مراقب (MEMBER)';

  void registerBrandingProvider(BrandingProvider bp) {
    _brandingProvider = bp;
  }

  AuthProvider() {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('safecore_current_user');
      if (savedUserJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(savedUserJson);
        _currentUser = UserProfile.fromJson(decoded);
        notifyListeners();
      }
    } catch (e) {
      // Ignore reading failures in offline setup
    }
  }

  Future<void> _saveSession(UserProfile profile) async {
    _currentUser = profile;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('safecore_current_user', jsonEncode(profile.toJson()));
    } catch (e) {
      // Offline local ignore
    }
    notifyListeners();
  }

  // 1. Instant One-Click Demo Evaluation Authentication
  Future<bool> quickLoginDemo(bool asAdmin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400)); // Smooth UX transition

    if (asAdmin) {
      await _saveSession(const UserProfile(
        id: 'usr_admin_petro_01',
        email: 'admin@petroapex.com',
        fullName: 'Eng. Khalid Al-Mansoor (HSE Director)',
        role: 'ADMIN',
        department: 'HSE Corporate Governance',
        branch: 'Jeddah Refinery Plant A',
        tenantId: 'petroapex',
        accessToken: 'mock_jwt_admin_token_2026',
      ));
      if (_brandingProvider != null) {
        _brandingProvider!.applyTenantBranding(TenantBranding.defaultPetroApex());
      }
    } else {
      await _saveSession(const UserProfile(
        id: 'usr_member_petro_02',
        email: 'inspector@petroapex.com',
        fullName: 'Tariq Ziad (Field Safety Inspector)',
        role: 'MEMBER',
        department: 'Field Operations & AI Scanner',
        branch: 'Jeddah Refinery Plant A',
        tenantId: 'petroapex',
        accessToken: 'mock_jwt_member_token_2026',
      ));
      if (_brandingProvider != null) {
        _brandingProvider!.applyTenantBranding(TenantBranding.defaultPetroApex());
      }
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // 2. Enterprise Setup & Admin Account Provisioning (Atomic Onboarding)
  Future<bool> setupEnterprise({
    required String tenantName,
    required String subdomain,
    required String adminEmail,
    required String adminPassword,
    required String adminFullName,
    required String department,
    required String branch,
    required Color primaryColor,
    required Color secondaryColor,
    required bool isRtl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    if (subdomain.isEmpty || adminEmail.isEmpty || adminPassword.isEmpty) {
      _errorMessage = 'يرجى إكمال الحقول الإخبارية الرئيسية لتأسيس الحساب المؤسسي.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Apply created tenant branding immediately to app theme
    final newBranding = TenantBranding(
      tenantId: subdomain.toLowerCase(),
      tenantName: tenantName,
      logoUrl: 'https://safecore-assets.s3.amazonaws.com/logos/$subdomain.png',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: const Color(0xFF38A169),
      fontFamily: 'IBM Plex Sans Arabic',
      isRtl: isRtl,
    );

    if (_brandingProvider != null) {
      _brandingProvider!.applyTenantBranding(newBranding);
    }

    // Atomically establish UserProfile with Role = ADMIN
    await _saveSession(UserProfile(
      id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
      email: adminEmail.toLowerCase(),
      fullName: adminFullName,
      role: 'ADMIN', // Exclusive sovereign assignment upon enterprise onboard
      department: department.isEmpty ? 'Executive Governance' : department,
      branch: branch.isEmpty ? 'Central Headquarters' : branch,
      tenantId: subdomain.toLowerCase(),
      accessToken: 'jwt_live_enterprise_${subdomain}_token',
    ));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // 3. Regular Credential Sign-In (For existing Admins or Members added by Admin)
  Future<bool> login(String subdomain, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final lowerEmail = email.toLowerCase();
    
    // Simulate smart role sorting based on email or demo credentials
    if (lowerEmail == 'admin@petroapex.com') {
      return quickLoginDemo(true);
    } else if (lowerEmail == 'inspector@petroapex.com') {
      return quickLoginDemo(false);
    }

    // Default authenticated session for custom added member by admin
    await _saveSession(UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: lowerEmail,
      fullName: lowerEmail.split('@').first.toUpperCase() + ' (Staff Member)',
      role: 'MEMBER', // Strict default role for regular sign-in
      department: 'Field Safety Operation',
      branch: 'Main Facility',
      tenantId: subdomain.toLowerCase(),
      accessToken: 'jwt_member_auth_$subdomain',
    ));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('safecore_current_user');
    } catch (e) {
      // Ignore local purge failure
    }
    notifyListeners();
  }
}
