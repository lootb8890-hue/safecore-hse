import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/**
 * Enterprise White-Label Branding Engine & Theme Provider.
 * Dynamically re-skins colors, typography, logos, and RTL layout direction
 * based on the authenticated enterprise organization payload.
 */
class TenantBranding {
  final String tenantId;
  final String tenantName;
  final String logoUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool isRtl;

  const TenantBranding({
    required this.tenantId,
    required this.tenantName,
    required this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.isRtl,
  });

  factory TenantBranding.defaultPetroApex() {
    return const TenantBranding(
      tenantId: 'petroapex',
      tenantName: 'PetroApex Energy & Refineries',
      logoUrl: 'https://safecore-assets.s3.amazonaws.com/logos/petroapex.png',
      primaryColor: Color(0xFF1A365D), // Corporate Deep Navy
      secondaryColor: Color(0xFFDD6B20), // Industrial Safety Orange
      accentColor: Color(0xFF38A169), // Compliance Green
      fontFamily: 'IBM Plex Sans Arabic',
      isRtl: false,
    );
  }

  factory TenantBranding.fromMap(Map<String, dynamic> data) {
    Color parseHexColor(String hex) {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse('0x$hex'));
    }

    return TenantBranding(
      tenantId: data['subdomain'] ?? data['id'] ?? 'default',
      tenantName: data['name'] ?? 'SafeCore HSE',
      logoUrl: data['logoUrl'] ?? '',
      primaryColor: data['primaryColor'] != null ? parseHexColor(data['primaryColor']) : const Color(0xFF1A365D),
      secondaryColor: data['secondaryColor'] != null ? parseHexColor(data['secondaryColor']) : const Color(0xFFDD6B20),
      accentColor: data['accentColor'] != null ? parseHexColor(data['accentColor']) : const Color(0xFF38A169),
      fontFamily: data['fontFamily'] ?? 'IBM Plex Sans Arabic',
      isRtl: data['isRtl'] == true || data['isRtl'] == 'true',
    );
  }
}

class BrandingProvider extends ChangeNotifier {
  TenantBranding _currentBranding = TenantBranding.defaultPetroApex();
  bool _isDarkMode = false;

  TenantBranding get branding => _currentBranding;
  bool get isDarkMode => _isDarkMode;
  TextDirection get textDirection => _currentBranding.isRtl ? TextDirection.rtl : TextDirection.ltr;

  void applyTenantBranding(TenantBranding newBranding) {
    _currentBranding = newBranding;
    notifyListeners();
  }

  void toggleThemeMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData generateThemeData() {
    final baseColor = _currentBranding.primaryColor;
    final secondaryColor = _currentBranding.secondaryColor;

    final baseTextTheme = _currentBranding.fontFamily.toLowerCase().contains('ibm')
        ? GoogleFonts.ibmPlexSansArabicTextTheme()
        : GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: baseColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: baseColor,
        primary: baseColor,
        secondary: secondaryColor,
        tertiary: _currentBranding.accentColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      textTheme: baseTextTheme.copyWith(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: _isDarkMode ? Colors.white : baseColor),
        bodyMedium: TextStyle(color: _isDarkMode ? Colors.white80 : Colors.black87),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? const Color(0xFF161B22) : Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: _isDarkMode ? Colors.white : baseColor),
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _isDarkMode ? Colors.white : baseColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
    );
  }
}
