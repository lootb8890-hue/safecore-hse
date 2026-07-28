import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/branding_engine.dart';
import '../../core/theme/glassmorphism.dart';

class AssetPin {
  final String id;
  final String assetNumber;
  final String name;
  final String layerType;
  final double x; // Relative coordinates 0.0 - 1000.0
  final double y;
  final String status;

  const AssetPin({
    required this.id,
    required this.assetNumber,
    required this.name,
    required this.layerType,
    required this.x,
    required this.y,
    required this.status,
  });
}

class LayoutCanvasScreen extends StatefulWidget {
  const LayoutCanvasScreen({Key? key}) : super(key: key);

  @override
  State<LayoutCanvasScreen> createState() => _LayoutCanvasScreenState();
}

class _LayoutCanvasScreenState extends State<LayoutCanvasScreen> {
  String _selectedLayer = 'ALL';
  final List<String> _layers = [
    'ALL',
    'EXTINGUISHER',
    'EMERGENCY_EXIT',
    'FIRST_AID',
    'ALARM',
    'ELECTRICAL',
    'HAZARD_ZONE',
    'SAFETY_EQUIPMENT',
    'CAMERA'
  ];

  final List<AssetPin> _pins = const [
    AssetPin(id: 'a1', assetNumber: 'EXT-901', name: '50kg Foam Extinguisher Unit', layerType: 'EXTINGUISHER', x: 220, y: 150, status: 'ACTIVE'),
    AssetPin(id: 'a2', assetNumber: 'EXIT-102', name: 'West Gate Emergency Fire Exit', layerType: 'EMERGENCY_EXIT', x: 750, y: 120, status: 'ACTIVE'),
    AssetPin(id: 'a3', assetNumber: 'AID-301', name: 'Trauma & Medical First Aid Box', layerType: 'FIRST_AID', x: 480, y: 320, status: 'ACTIVE'),
    AssetPin(id: 'a4', assetNumber: 'CAM-505', name: 'Thermal Imaging Gas Detector Cam', layerType: 'CAMERA', x: 310, y: 440, status: 'ACTIVE'),
    AssetPin(id: 'a5', assetNumber: 'ELEC-808', name: 'Main High-Voltage Distribution Board', layerType: 'ELECTRICAL', x: 680, y: 410, status: 'ATTENTION_NEEDED'),
  ];

  @override
  Widget build(BuildContext context) {
    final branding = Provider.of<BrandingProvider>(context).branding;
    final filteredPins = _selectedLayer == 'ALL' ? _pins : _pins.where((p) => p.layerType == _selectedLayer).toList();

    return Column(
      children: [
        // Layer Toggle Header Bar
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _layers.length,
            separatorBuilder: (context, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final layer = _layers[index];
              final isSelected = _selectedLayer == layer;
              return ChoiceChip(
                label: Text(layer.replaceAll('_', ' ')),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedLayer = layer);
                },
                selectedColor: branding.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : branding.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                backgroundColor: branding.primaryColor.withOpacity(0.08),
              );
            },
          ),
        ),

        // Interactive Canvas Studio
        Expanded(
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(500),
                child: Container(
                  width: 1000,
                  height: 600,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A202C),
                    border: Border.all(color: branding.secondaryColor, width: 3),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
                  ),
                  child: Stack(
                    children: [
                      // Architectural Blueprint Grid Representation
                      CustomPaint(
                        size: const Size(1000, 600),
                        painter: BlueprintGridPainter(branding.primaryColor),
                      ),
                      Center(
                        child: Text(
                          'INDUSTRIAL PLANT A - FLOOR PLAN SCHEMA',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.12), letterSpacing: 3),
                        ),
                      ),
                      // Interactive Digital Pins
                      for (final pin in filteredPins) _buildPinWidget(context, pin, branding),
                    ],
                  ),
                ),
              ),

              // Floating Controls & Legend Overlay
              Positioned(
                bottom: 20,
                left: 20,
                child: GlassContainer(
                  width: 320,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('INTERACTIVE CANVAS COMMAND', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text('Viewing Layer: ${_selectedLayer.replaceAll('_', ' ')} (${filteredPins.length} Twins)', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      const Text('💡 Pinch to zoom. Drag pins in Admin mode to readjust coordinates.', style: TextStyle(color: Colors.amber, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinWidget(BuildContext context, AssetPin pin, TenantBranding branding) {
    IconData icon;
    Color color;
    switch (pin.layerType) {
      case 'EXTINGUISHER':
        icon = Icons.fire_extinguisher;
        color = Colors.redAccent;
        break;
      case 'EMERGENCY_EXIT':
        icon = Icons.exit_to_app;
        color = Colors.green;
        break;
      case 'FIRST_AID':
        icon = Icons.medical_services;
        color = Colors.blue;
        break;
      case 'CAMERA':
        icon = Icons.videocam;
        color = Colors.purpleAccent;
        break;
      case 'ELECTRICAL':
        icon = Icons.electrical_services;
        color = Colors.orange;
        break;
      default:
        icon = Icons.location_on;
        color = branding.secondaryColor;
    }

    return Positioned(
      left: pin.x - 20,
      top: pin.y - 20,
      child: GestureDetector(
        onTap: () => _showAssetModal(context, pin, branding),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 10, spreadRadius: 2)],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  void _showAssetModal(BuildContext context, AssetPin pin, TenantBranding branding) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pin.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: branding.primaryColor)),
                Chip(
                  label: Text(pin.status, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  backgroundColor: pin.status == 'ACTIVE' ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Asset ID # ${pin.assetNumber}  •  Layer: ${pin.layerType}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.history, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Last Inspection: Verified compliant 5 days ago', style: TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Launching Inspection Checklist for ${pin.assetNumber}...')));
                },
                icon: const Icon(Icons.assignment_turned_in),
                label: const Text('EXECUTE SAFETY AUDIT CHECK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlueprintGridPainter extends CustomPainter {
  final Color baseColor;
  BlueprintGridPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = baseColor.withOpacity(0.2)
      ..strokeWidth = 1.0;

    const gridSize = 40.0;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
