import 'dart:convert';
import 'package:flutter/foundation.dart';

/**
 * Offline-First Persistent local repository using in-memory / JSON caching simulation
 * ready for direct Hive Box wiring across mobile and web environments.
 * Ensures field inspectors can complete 100% of checkups inside deep basements or ship decks
 * without active cellular network connectivity.
 */
class OfflineStorageService extends ChangeNotifier {
  static final OfflineStorageService _instance = OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  final List<Map<String, dynamic>> _pendingInspections = [];
  final Map<String, dynamic> _cachedAssets = {};
  final Map<String, dynamic> _cachedForms = {};
  final Map<String, dynamic> _cachedLayouts = {};
  bool _isOfflineModeActive = false;

  bool get isOfflineModeActive => _isOfflineModeActive;
  int get pendingSyncCount => _pendingInspections.length;
  List<Map<String, dynamic>> get pendingInspections => _pendingInspections;

  void setOfflineMode(bool offline) {
    _isOfflineModeActive = offline;
    notifyListeners();
  }

  // Cache assets locally when online
  void cacheAsset(String assetId, Map<String, dynamic> assetData) {
    _cachedAssets[assetId] = assetData;
  }

  Map<String, dynamic>? getCachedAsset(String assetId) {
    return _cachedAssets[assetId];
  }

  // Save completed inspection locally while underground / offline
  Future<void> saveOfflineInspection(Map<String, dynamic> recordPayload) async {
    recordPayload['clientOfflineTimestamp'] = DateTime.now().toIso8601String();
    recordPayload['syncStatus'] = 'PENDING_UPLOAD';
    _pendingInspections.add(recordPayload);
    
    debugPrint('📁 [OfflineStorage] Saved field inspection locally. Total pending upload: ${_pendingInspections.length}');
    notifyListeners();
  }

  // Clear synchronized records after successful server upload
  void removeSyncedRecord(int index) {
    if (index >= 0 && index < _pendingInspections.length) {
      _pendingInspections.removeAt(index);
      notifyListeners();
    }
  }

  void clearAllSynced() {
    _pendingInspections.clear();
    notifyListeners();
  }
}
