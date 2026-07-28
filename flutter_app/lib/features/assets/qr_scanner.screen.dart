import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../core/theme/branding_engine.dart';
import '../../core/theme/glassmorphism.dart';
import '../../core/offline_db/offline_storage_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final TextEditingController _inputCtrl = TextEditingController(text: 'EXT-9901-A');
  Map<String, dynamic>? _scannedAsset;

  void _simulateScan(String code) {
    setState(() {
      _scannedAsset = {
        'assetNumber': code,
        'name': '50kg Industrial Foam Fire Extinguisher',
        'layerType': 'EXTINGUISHER',
        'manufacturer': 'Kidde Industrial Safety Ltd',
        'status': 'ACTIVE',
        'location': 'Plant A - Central Operations Floor 1',
        'lastInspection': '2026-07-20 (Compliant)',
        'nextInspection': '2026-07-27 (Due Today)',
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _simulateScan(_inputCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final branding = Provider.of<BrandingProvider>(context).branding;
    final offlineService = Provider.of<OfflineStorageService>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ASSET QR & BARCODE INSPECTOR', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: branding.secondaryColor, letterSpacing: 1.1)),
          const SizedBox(height: 6),
          Text('Digital Twin Verification Studio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: branding.primaryColor)),
          const SizedBox(height: 20),

          // Camera Scanner Simulation View & Search Input
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        decoration: InputDecoration(
                          labelText: 'Scan QR URL or Input Asset / Barcode Number',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.qr_code_scanner),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _simulateScan(_inputCtrl.text),
                      style: ElevatedButton.styleFrom(backgroundColor: branding.primaryColor),
                      child: const Text('SCAN ASSET'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Display Asset Lifecycle Cards & Print Label preview if scanned
          if (_scannedAsset != null) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: branding.primaryColor.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_scannedAsset!['layerType'], style: TextStyle(fontWeight: FontWeight.bold, color: branding.secondaryColor, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(_scannedAsset!['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: branding.primaryColor)),
                            Text('Tag ID: #${_scannedAsset!['assetNumber']}', style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
                        child: const Text('ACTIVE COMPLIANT', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCell('Physical Placement', _scannedAsset!['location'], Icons.place_outlined),
                      ),
                      Expanded(
                        child: _buildDetailCell('Next Inspection', _scannedAsset!['nextInspection'], Icons.schedule, isAlert: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Printable Adhesive Sticker Preview Card (incorporating Logo, QR & Linear Barcode)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade200, style: BorderStyle.solid, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text('INDUSTRIAL PRINTABLE ADHESIVE STICKER PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: branding.primaryColor, letterSpacing: 0.8)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // QR Code Graphic
                            Column(
                              children: [
                                QrImageView(
                                  data: 'safecore://asset?id=${_scannedAsset!['assetNumber']}',
                                  version: QrVersions.auto,
                                  size: 110.0,
                                ),
                                const SizedBox(height: 4),
                                const Text('QR Smart Link', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            // Barcode Linear Graphic
                            Column(
                              children: [
                                SizedBox(
                                  width: 160,
                                  height: 70,
                                  child: BarcodeWidget(
                                    barcode: Barcode.code128(),
                                    data: '880192384752',
                                    drawText: true,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Asset #${_scannedAsset!['assetNumber']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Button to execute immediate checkup
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Simulate completing an offline checkup
                        offlineService.saveOfflineInspection({
                          'assetId': _scannedAsset!['assetNumber'],
                          'status': 'COMPLETED',
                          'answers': {'f_1': true, 'f_2': true, 'f_3': 150},
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Inspection Checklist recorded locally & scheduled for automatic cloud sync!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: branding.secondaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                      icon: const Icon(Icons.verified, size: 24),
                      label: const Text('EXECUTE & SUBMIT SAFETY AUDIT CHECKUP', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCell(String title, String value, IconData icon, {bool isAlert = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: isAlert ? Colors.orange.shade700 : Colors.blueGrey, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isAlert ? Colors.orange.shade800 : Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}
