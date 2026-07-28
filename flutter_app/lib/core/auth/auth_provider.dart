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

  // Enterprise status
  bool _isEnterpriseSetup = false;
  String _tenantName = '';
  String _subdomain = '';
  String _adminEmail = '';
  String _adminPassword = '';
  String _adminFullName = '';

  // List of pre-authorized or registered team members
  List<Map<String, dynamic>> _membersList = [];

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool get isAdmin => _currentUser?.role.toUpperCase() == 'ADMIN';
  bool get isEnterpriseSetup => _isEnterpriseSetup;
  String get tenantName => _tenantName;
  String get subdomain => _subdomain;
  String get adminEmail => _adminEmail;
  String get adminFullName => _adminFullName;

  List<Map<String, dynamic>> get membersList => _membersList;

  String get roleBadgeText => isAdmin ? '★ مسؤول عام (ADMIN)' : '🛡️ عضو مراقب (MEMBER)';

  void registerBrandingProvider(BrandingProvider bp) {
    _brandingProvider = bp;
    // Apply loaded tenant branding on startup if set
    if (_isEnterpriseSetup && _brandingProvider != null) {
      _applyLoadedBranding();
    }
  }

  AuthProvider() {
    _loadState();
  }

  // Load setup configurations and accounts from SharedPreferences
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnterpriseSetup = prefs.getBool('safecore_enterprise_setup') ?? false;
      _tenantName = prefs.getString('safecore_tenant_name') ?? '';
      _subdomain = prefs.getString('safecore_subdomain') ?? '';
      _adminEmail = prefs.getString('safecore_admin_email') ?? '';
      _adminPassword = prefs.getString('safecore_admin_password') ?? '';
      _adminFullName = prefs.getString('safecore_admin_fullname') ?? '';

      // Load members
      final membersJson = prefs.getString('safecore_members_list');
      if (membersJson != null) {
        final List<dynamic> decoded = jsonDecode(membersJson);
        _membersList = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        // Pre-populate with default demo inspector member
        _membersList = [
          {
            'email': 'inspector@petroapex.com',
            'fullName': 'طارق زياد (Tariq Ziad)',
            'department': 'قسم المراقبة الميدانية ومسح الأمان',
            'branch': 'مصفاة جدة - المنطقة التشغيلية (أ)',
            'password': 'SafeCore@2026!',
            'isRegistered': true,
            'isActive': true,
          },
          {
            'email': 's.ghamdi@petroapex.com',
            'fullName': 'سارة الغامدي (Sarah Al-Ghamdi)',
            'department': 'إدارة الرصد البيئي ومكافحة الانبعاثات',
            'branch': 'المقر التجريبي - ينبع الصناعية',
            'password': 'SafeCore@2026!',
            'isRegistered': true,
            'isActive': true,
          }
        ];
        await _saveMembersToPrefs();
      }

      // Pre-populate default admin if setup is false
      if (!_isEnterpriseSetup) {
        _tenantName = 'شركة نورس لصناعات الطاقة والسلامة';
        _subdomain = 'petroapex';
        _adminEmail = 'admin@petroapex.com';
        _adminPassword = 'SafeCore@2026!';
        _adminFullName = 'م. خالد المنصور (مدير السلامة)';
      }

      // Load active logged-in user session
      final savedUserJson = prefs.getString('safecore_current_user');
      if (savedUserJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(savedUserJson);
        _currentUser = UserProfile.fromJson(decoded);
      }

      if (_isEnterpriseSetup && _brandingProvider != null) {
        _applyLoadedBranding();
      }
      notifyListeners();
    } catch (e) {
      // Offline local ignore
    }
  }

  void _applyLoadedBranding() {
    if (_brandingProvider == null) return;
    _brandingProvider!.applyTenantBranding(TenantBranding(
      tenantId: _subdomain.toLowerCase(),
      tenantName: _tenantName,
      logoUrl: 'https://safecore-assets.s3.amazonaws.com/logos/$_subdomain.png',
      primaryColor: const Color(0xFF1E5E3A), // Match the official green HSE color
      secondaryColor: const Color(0xFF1B2533),
      accentColor: const Color(0xFF38A169),
      fontFamily: 'IBM Plex Sans Arabic',
      isRtl: true,
    ));
  }

  Future<void> _saveMembersToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('safecore_members_list', jsonEncode(_membersList));
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _saveSession(UserProfile profile) async {
    _currentUser = profile;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('safecore_current_user', jsonEncode(profile.toJson()));
    } catch (e) {
      // Ignore
    }
    notifyListeners();
  }

  // 1. Setup Enterprise (Admin Account Provisioning)
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

    if (subdomain.isEmpty || adminEmail.isEmpty || adminPassword.isEmpty || adminFullName.isEmpty) {
      _errorMessage = 'يرجى إكمال الحقول الإخبارية الرئيسية لتأسيس الحساب المؤسسي.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('safecore_enterprise_setup', true);
      await prefs.setString('safecore_tenant_name', tenantName);
      await prefs.setString('safecore_subdomain', subdomain);
      await prefs.setString('safecore_admin_email', adminEmail);
      await prefs.setString('safecore_admin_password', adminPassword);
      await prefs.setString('safecore_admin_fullname', adminFullName);

      _isEnterpriseSetup = true;
      _tenantName = tenantName;
      _subdomain = subdomain;
      _adminEmail = adminEmail;
      _adminPassword = adminPassword;
      _adminFullName = adminFullName;

      // Apply branding
      _applyLoadedBranding();

      // Log in as Admin automatically
      await _saveSession(UserProfile(
        id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
        email: adminEmail.toLowerCase(),
        fullName: adminFullName,
        role: 'ADMIN',
        department: department.isEmpty ? 'الإدارة العامة لحوكمة الأمان' : department,
        branch: branch.isEmpty ? 'المقر الرئيسي' : branch,
        tenantId: subdomain.toLowerCase(),
        accessToken: 'jwt_live_enterprise_${subdomain}_token',
      ));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء حفظ الإعدادات: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 2. Admin adds/pre-registers a member from Sidebar/Member Roster
  Future<bool> addMemberByAdmin({
    required String fullName,
    required String email,
    required String department,
    required String branch,
    required String password,
  }) async {
    final lowerEmail = email.trim().toLowerCase();
    
    // Check if already exists
    final index = _membersList.indexWhere((element) => element['email'] == lowerEmail);
    if (index >= 0) {
      return false; // Email already in list
    }

    _membersList.insert(0, {
      'email': lowerEmail,
      'fullName': fullName,
      'department': department,
      'branch': branch,
      'password': password,
      'isRegistered': false, // Needs member sign-up registration to activate
      'isActive': true,
    });

    await _saveMembersToPrefs();
    notifyListeners();
    return true;
  }

  // 3. Member Sign-Up: Register a pre-authorized email
  Future<bool> registerMember({
    required String email,
    required String password,
    required String fullName,
    required String department,
    required String branch,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    final lowerEmail = email.trim().toLowerCase();

    // Check if the email exists in the pre-registered list from the admin
    final index = _membersList.indexWhere((element) => element['email'] == lowerEmail);
    if (index < 0) {
      _errorMessage = 'عذراً، هذا البريد غير مصرح له بالتسجيل. يجب على الأدمن إضافتك أولاً من لوحة التحكم الجانبية.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final member = _membersList[index];
    if (member['isRegistered'] == true) {
      _errorMessage = 'هذا الحساب مسجّل بالفعل مسبقاً، يرجى التوجه لصفحة تسجيل الدخول.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Activate the member account
    member['password'] = password;
    if (fullName.isNotEmpty) member['fullName'] = fullName;
    if (department.isNotEmpty) member['department'] = department;
    if (branch.isNotEmpty) member['branch'] = branch;
    member['isRegistered'] = true;
    member['isActive'] = true;

    _membersList[index] = member;
    await _saveMembersToPrefs();

    // Log the member in automatically
    await _saveSession(UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: lowerEmail,
      fullName: member['fullName'],
      role: 'MEMBER',
      department: member['department'],
      branch: member['branch'],
      tenantId: _subdomain.toLowerCase(),
      accessToken: 'jwt_member_auth_token_${_subdomain}',
    ));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Check if a member email is pre-registered by Admin and eligible for registration
  Map<String, dynamic>? checkMemberEmailEligibility(String email) {
    final lowerEmail = email.trim().toLowerCase();
    final index = _membersList.indexWhere((element) => element['email'] == lowerEmail);
    if (index >= 0) {
      return _membersList[index];
    }
    return null;
  }

  // 4. Standard Sign-In
  Future<bool> login(String subdomain, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    final lowerEmail = email.trim().toLowerCase();

    // Check Subdomain (must match configured subdomain)
    if (_isEnterpriseSetup && subdomain.trim().toLowerCase() != _subdomain.toLowerCase()) {
      _errorMessage = 'معرف المنشأة السحابي (Tenant Subdomain) غير صحيح.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 1. Authenticate as Admin
    if (lowerEmail == _adminEmail.toLowerCase() && password == _adminPassword) {
      await _saveSession(UserProfile(
        id: 'admin_session',
        email: _adminEmail.toLowerCase(),
        fullName: _adminFullName,
        role: 'ADMIN',
        department: 'الإدارة العامة لحوكمة الأمان',
        branch: 'المقر الرئيسي',
        tenantId: _subdomain.toLowerCase(),
        accessToken: 'jwt_live_enterprise_${_subdomain}_admin_token',
      ));
      _isLoading = false;
      notifyListeners();
      return true;
    }

    // 2. Authenticate as Member from members roster
    final index = _membersList.indexWhere((element) => element['email'] == lowerEmail);
    if (index >= 0) {
      final member = _membersList[index];
      if (member['password'] == password) {
        if (member['isActive'] != true) {
          _errorMessage = 'تم إيقاف صلاحية هذا الحساب مؤقتاً من قبل مشرف النظام.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        if (member['isRegistered'] != true) {
          _errorMessage = 'تم إضافة حسابك بواسطة الأدمن ولكن يجب إتمام التسجيل وتفعيل الحساب أولاً.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        await _saveSession(UserProfile(
          id: 'usr_session_${DateTime.now().millisecondsSinceEpoch}',
          email: lowerEmail,
          fullName: member['fullName'] ?? 'عضو فريق السلامة',
          role: 'MEMBER',
          department: member['department'] ?? 'التفتيش الميداني',
          branch: member['branch'] ?? 'الموقع التشغيلي',
          tenantId: _subdomain.toLowerCase(),
          accessToken: 'jwt_live_enterprise_${_subdomain}_member_token',
        ));
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Toggle active/inactive status of member
  Future<void> toggleMemberStatus(String email, bool isActive) async {
    final index = _membersList.indexWhere((element) => element['email'] == email);
    if (index >= 0) {
      _membersList[index]['isActive'] = isActive;
      await _saveMembersToPrefs();
      notifyListeners();
    }
  }

  // Delete/Remove member
  Future<void> removeMember(String email) async {
    _membersList.removeWhere((element) => element['email'] == email);
    await _saveMembersToPrefs();
    notifyListeners();
  }
  // Quick one-click demo login for instant evaluation
  Future<bool> quickLoginDemo(bool asAdmin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    // Ensure enterprise is marked as set up for demo
    if (!_isEnterpriseSetup) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('safecore_enterprise_setup', true);
        await prefs.setString('safecore_tenant_name', 'شركة نورس لصناعات الطاقة والسلامة');
        await prefs.setString('safecore_subdomain', 'petroapex');
        await prefs.setString('safecore_admin_email', 'admin@petroapex.com');
        await prefs.setString('safecore_admin_password', 'SafeCore@2026!');
        await prefs.setString('safecore_admin_fullname', 'م. خالد المنصور (مدير السلامة)');
        _isEnterpriseSetup = true;
        _tenantName = 'شركة نورس لصناعات الطاقة والسلامة';
        _subdomain = 'petroapex';
        _adminEmail = 'admin@petroapex.com';
        _adminPassword = 'SafeCore@2026!';
        _adminFullName = 'م. خالد المنصور (مدير السلامة)';
      } catch (e) {
        // Ignore
      }
    }

    _applyLoadedBranding();

    if (asAdmin) {
      await _saveSession(const UserProfile(
        id: 'usr_admin_petro_01',
        email: 'admin@petroapex.com',
        fullName: 'م. خالد المنصور (مدير السلامة)',
        role: 'ADMIN',
        department: 'الإدارة العامة لحوكمة الأمان',
        branch: 'المقر الرئيسي',
        tenantId: 'petroapex',
        accessToken: 'mock_jwt_admin_token_2026',
      ));
    } else {
      await _saveSession(const UserProfile(
        id: 'usr_member_petro_02',
        email: 'inspector@petroapex.com',
        fullName: 'طارق زياد (مراقب ميداني)',
        role: 'MEMBER',
        department: 'قسم المراقبة الميدانية ومسح الأمان',
        branch: 'مصفاة جدة - المنطقة التشغيلية (أ)',
        tenantId: 'petroapex',
        accessToken: 'mock_jwt_member_token_2026',
      ));
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> resetSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isEnterpriseSetup = false;
    _currentUser = null;
    _membersList = [];
    _tenantName = '';
    _subdomain = '';
    _adminEmail = '';
    _adminPassword = '';
    _adminFullName = '';
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('safecore_current_user');
    } catch (e) {
      // Ignore
    }
    notifyListeners();
  }
}
