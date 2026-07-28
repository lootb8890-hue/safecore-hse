# Enterprise UI/UX Design System Specification - SafeCore HSE Platform

This document details the architectural rules and visual specifications for the **SafeCore HSE Platform** design system across all supported interfaces: Android APK, iOS App Store, Web PWA, and the Executive Admin Dashboard.

---

## 1. Core Design Axioms
1. **Material Design 3 (M3) Foundation:** Complete embrace of dynamic color spaces, elevated surface hierarchy, and accessible interactive target sizing (minimum touch targets of `48x48dp` for field safety gloved operations).
2. **True RTL & LTR Bi-directionality:** Seamless layout mirroring without layout disruption when toggling between Arabic (RTL) and English/International languages (LTR).
3. **Glassmorphism & Surface Depth:** Use of subtle backdrop frosted glass blurring (`BackdropFilter` with Sigma X:12 / Sigma Y:12) over dark/vibrant gradient canvases to highlight urgent alarms and statistical KPIs without visual clutter.
4. **Vector Iconography Exclusive (SVG):** Zero raster bitmapped icons in functional workflows. Every icon (extinguishers, hazards, valves, avatars, layout pins) scales infinitely via SVG format.
5. **Micro-Animations (Lottie):** Interactive state feedback powered by JSON Lottie animations for:
   - Zero-latency siren triggers (Pulsing Red Radiation Alert)
   - QR scanner framing and completion checkmarks
   - Background data synchronization progress loops
   - Offline database state indicators (Disconnected shield vs. Connected Cloud).

---

## 2. Typography & Fonts Architecture
The platform restricts font selections to two world-class enterprise typography families, loaded via Google Fonts or embedded offline assets:
1. **IBM Plex Sans Arabic:** Engineered for maximum legibility in technical Arabic manuals, safety instructions, and high-density tabular numerical monitoring.
2. **Inter:** Built for precise international numbers, codes, English labels, and interactive dashboard analytics.

### Font Scale (Type Hierarchy):
- **Display Large (Emergency Alert Header):** 32pt / Bold (700) / Line Height: 40pt
- **Headline Medium (Section & Screen Titles):** 24pt / Semi-Bold (600) / Line Height: 32pt
- **Title Medium (Asset Cards & Layer Switches):** 18pt / Medium (500) / Line Height: 24pt
- **Body Large (SOP Text & Form Field Labels):** 16pt / Regular (400) / Line Height: 24pt
- **Label Small (QR Footers, Asset IDs, Timestamps):** 12pt / Semi-Bold (600) / Line Height: 16pt / Letter spacing: 0.5px.

---

## 3. White-Label Color Token Architecture (Dark & Light Schemes)
Tenants dynamically inject primary and secondary seeds. The Flutter application builds complementary tones programmatically:

### 3.1 Default Enterprise Palette (SafeCore Navy & Safety Amber)
- **Primary Color:** `#1A56DB` (Deep Industrial Cobalt)
- **Secondary Color:** `#0E317A` (Executive Navy)
- **Emergency Accent (Siren / Critical Hazard):** `#F05252` (High-Visibility Safety Crimson)
- **Warning Accent (Expired Asset / Inspection Due):** `#FCE96A` (Warning Caution Amber)
- **Success Accent (Compliant / Inspection Passed):** `#31C48D` (Safety Verified Green)

### 3.2 Dark Mode vs. Light Mode Surfaces
| Surface Token | Light Mode Value | Dark Mode Value (OLED & Low Light Safe) |
| :--- | :--- | :--- |
| **App Canvas / Background** | `#F8F9FA` (Clean Off-White) | `#0D1117` (Deep Industrial Carbon) |
| **Card / Glass Surface** | `rgba(255, 255, 255, 0.75)` | `rgba(22, 27, 34, 0.80)` |
| **Border / Stroke Accent** | `#E5E7EB` (Subtle Neutral Gray) | `#30363D` (Subtle Dark Slate) |
| **Primary Typography** | `#111827` (Charcoal Black) | `#F0F6FC` (Crisp Lunar White) |
| **Secondary Metadata Text** | `#6B7280` (Muted Steel Gray) | `#8B949E` (Muted Titanium Gray) |

---

## 4. Component Technical Specs (Flutter Implementation Guidelines)

### 4.1 Interactive Company Layout Canvas (Floor Plan Studio)
- **Canvas Viewport:** Built using Flutter's `InteractiveViewer` combined with an underlying `CustomPaint` or image tile provider.
- **Pin Overlay System:** Pins render on top of the layout utilizing proportional coordinates `(x / layout_width, y / layout_height)` to ensure perfect placement alignment regardless of device display dimensions or zoom scaling.
- **Layer Bar & Legend:** Floating glassmorphic dock at the bottom of the layout viewer containing toggles for 8 specialized layers:
  `[ 🔥 Extinguishers ] [ 🚪 Exits ] [ 🩹 First Aid ] [ 🚨 Alarms ] [ ⚡ Electrical ] [ ⚠️ Hazards ] [ 🛡️ Safety Eq ] [ 📹 Cameras ]`

### 4.2 The Emergency Center ( Red Alarm Button )
- **Placement:** Anchored dead-center in the application Bottom Navigation Bar, or elevated floating above dashboard navigation on Web/PWA.
- **Visual Appearance:** Radiant glowing crimson button (`#F05252`) featuring a pulsing outer Lottie ring during calm state.
- **Interlock Modal:** Pressing the button expands a full-screen blurred emergency interlock modal presenting 6 distinct emergency category triggers (Fire, Injury, Gas, Electrical, HazMat, Evacuate). Requires a rapid double-tap or swipe-to-confirm gesture to prevent accidental false alarms in industrial pocket environments.

### 4.3 QR Printable Adhesive Sticker Layout Spec
When generating PDF labels in-app or via backend service, each label conforms to a standard industrial waterproof adhesive dimension (`100mm x 50mm` or `70mm x 35mm`):
```
┌────────────────────────────────────────────────────────┐
│  [ TENANT LOGO HERE ]       SAFECORE HSE CERTIFIED     │
├────────────────────────────────────────────────────────┤
│  ASSET ID: EXT-ZN-4-001                                │
│  TYPE: Powder Fire Extinguisher 6kg                    │
│                                                        │
│  ┌───────────────┐   BARCODE:                          │
│  │               │   ║││║║│││║│║│║║││║║│││             │
│  │    QR CODE    │   10098221921                       │
│  │               │                                     │
│  └───────────────┘   INSPECTION FREQ: MONTHLY          │
└────────────────────────────────────────────────────────┘
```
