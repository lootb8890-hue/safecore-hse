# Software Requirements Specification (SRS) - SafeCore HSE Platform

## 1. Introduction & Executive Summary
**SafeCore HSE Platform** is a world-class, multi-tenant, white-label cloud and on-premise SaaS enterprise system engineered for Occupational Health, Safety, and Environment (HSE) management. Designed to operate across extreme industrial environments—including oil & gas refineries, ports, airports, megaconstruction sites, modern hospitals, and university campuses—SafeCore delivers real-time hazard prevention, dynamic safety asset tracking via digital twins, zero-latency emergency broadcasting, offline-first execution, and native AI-powered safety analytics.

### 1.1 Project Objectives
- **Zero Code Customization (True White-Label):** Seamless dynamic injection of corporate identity, logos, color themes, branches, and department organizational structures per tenant without codebase recompilation.
- **Unified Clean Codebase:** Single cross-platform Flutter architecture producing high-performance compiled artifacts for Android (APK / Google Play), iOS (App Store), Web (PWA), and dedicated Admin Web Dashboard.
- **Offline-First Resilience:** Uninterrupted core workflows (asset QR inspections, hazard reports, permits, emergency alerts, digital sign-offs) fully operational without internet connectivity, driven by deterministic delta-synchronization engines.
- **Zero-Latency Emergency Response:** Integrated instantaneous emergency broadcasting and real-time interactive facility mapping replacing static geospatial services with scalable architectural CAD/PDF conversion overlays.
- **Append-Only Audit & Compliance Readiness:** Meeting strict global HSE regulations (OSHA, ISO 45001, NEBOSH) through immutable, tamper-proof audit trails.

---

## 2. Stakeholder Roles & Access Control Matrix
The system strictly consolidates structural complexity into exactly two clearly differentiated operational roles: **Admin (Tenant Administrator)** and **Member (Safety Officer / Inspector / Employee)**.

### 2.1 Role Capabilities Matrix

| Functional Area | Admin (Administrator) | Member (Safety Team & Staff) |
| :--- | :--- | :--- |
| **User & Org Management** | Create, update, deactivate users; password resets; configure tenant identity, branches, & departments. | View profile and team members within allowed groups. |
| **Facility Floor Plans** | Upload architectural layouts (PDF, PNG, JPG, DWG); calibrate scales; organize structural layers. | View interactive maps, search pinned safety assets, view safety zones. |
| **Safety Asset Engine** | Add, modify, delete assets; define scheduled periodic maintenance rules; bulk print QR/Barcode labels. | Add, modify, and delete local field safety assets; scan QR/Barcodes; view asset timeline and maintenance history. |
| **Inspection Form Builder** | Visual drag-and-drop form building (Text, GPS, Signature, Camera, Ratings, Files); assign schedule frequencies. | Execute inspection forms via QR scan or task queue; capture photos, sign off digitally, lodge readings offline/online. |
| **Emergency & Incidents** | View executive incident maps; trigger sirens; close and archive incident investigations; review AI summaries. | Trigger immediate emergency siren (Fire, Injury, Gas, HazMat, Evacuation, Electrical); upload on-site live media & action notes. |
| **Task Management** | Create tasks, assign ownership, set priority and deadline intervals; monitor KPI completion rates. | View "Today's Tasks", execute assigned checkups, update completion status, log work permits. |
| **Document & SOP Center** | Upload and manage safety policies, standard operating procedures (SOP), MSDS sheets, and governance media. | Download and consult MSDS/SOP documents (cached for offline field viewing). |
| **Internal Team Chat** | Moderate discussions, broadcast announcements, create specialized investigation or project groups. | Send real-time messages, audio recordings, video clips, GPS coordinates, PDFs, and reply/pin messages in team channels. |
| **Audit Logs & Reports** | Access immutable system audit logs; generate branded PDF, Excel, and CSV corporate analytics reports. | Access specific operational reports and personal completed inspection summaries. |

---

## 3. Detailed System Architectural Modules

### 3.1 Corporate Identity & Tenancy Customization
- **Dynamic CSS/Theme Tokens:** Admin enters Corporate Name, Hex Color Palette (Primary, Secondary, Surface Accent), Organization Hierarchy (Branches -> Projects -> Departments), and Corporate Logo URLs. 
- **Application Startup Injection:** During login or token validation, the API returns a branded payload (`TenantBrandingDTO`). Flutter applications dynamically transform AppBar styles, splash animations, typography, and report headers in real-time.

### 3.2 Interactive Facility Layout Engine (Alternative to Google Maps)
- **Problem Solved:** Traditional GPS maps lack multi-story indoor accuracy required for indoor fire extinguishers, electrical panels, or hazardous production floors.
- **Interactive Layout Canvas:** Admins upload blueprints (PDF, High-res PNG/JPG, or DWG rendering exports). The system normalizes these into scalable vector graphics (SVG) or high-resolution tiled canvas viewports.
- **Interactive Features:** Smooth zoom, fluid 2D pan, drop-and-drag pin placement, dynamic pin positioning with responsive coordinates `(X, Y)` relative to layout dimensions.
- **Layer Toggle System (8 Specialized Layers):**
  1. Fire Extinguishers (طفاية الحريق)
  2. Emergency Exits (مخارج الطوارئ)
  3. First Aid Kits & Boxes (الإسعافات الأولية)
  4. Alarm Panels & Sirens (أجهزة الإنذار)
  5. Electrical Panels & Transformers (لوحات الكهرباء)
  6. Hazard & Restricted Zones (مناطق الخطر)
  7. Personal Safety Equipment & PPE Stations (معدات السلامة)
  8. Security & Thermal Cameras (الكاميرات)

### 3.3 Digital Safety Assets & Automated QR Label System
Every piece of hardware or critical installation possesses a digital twin characterized by a **Unique ID**, cryptographic **QR Code**, and optional **Barcode**.
- **Supported Assets:** Fire Extinguishers, Emergency Showers, Eye Wash Stations, Cranes, Storage Tanks, Generators, Scopes, First Aid Boxes.
- **Asset Lifecycle Database:** Tracks asset model, serial number, installation date, warranty expiration, current status (`ACTIVE`, `MAINTENANCE_REQUIRED`, `EXPIRED`, `DECOMMISSIONED`), inspection intervals, and full inspection chronological timeline.
- **Automated Label Generator:** Upon creation, the backend compiles a vectorized, print-ready PDF adhesive sticker containing:
  - Enterprise Tenant Logo
  - Plain text Asset Title and Code Number (e.g., `EXT-BNG-0042`)
  - High-error-correction QR Code (incorporating deep-linking payload: `safecore://asset?id=uid_8841`)
  - Standard Linear Barcode (Code 128 / EAN-13).

### 3.4 Dynamic Inspection Form Builder & Automated Scheduler
- **No-Code Visual Form Designer:** Admins assemble customized evaluation questionnaires using 14 native input types:
  `Text`, `Numeric Threshold`, `Boolean Checkbox`, `Custom Dropdown`, `Live Camera Snapshot`, `Gallery Image Upload`, `Digital Electronic Signature`, `Date Picker`, `Time Stamp`, `GPS Coordinate Capture`, `Mandatory QR Scan Match`, `Barcode Validator`, `File Attachment`, and `Star Rating (1-5)`.
- **Automated Scheduler & Alert Engine:** Schedules configured for: Daily, Weekly, Monthly, Quarterly, Bi-Annual, and Annual cycles. The Redis-powered cron scheduler generates inspection orders inside members' task lists 24 hours prior to deadline and triggers automated push/in-app notifications.

### 3.5 Zero-Latency Emergency Center ( Red Siren Button )
- **Prominent UI Placement:** A glowing, high-contrast Red Alarm action button accessible on the core navigation bar of all application variants at all times.
- **Emergency Incident Typification (6 Classes):** Fire (حريق), Medical Injury (إصابة), Gas Leak (تسرب غاز), Electrical Short (تماس كهربائي), Hazardous Material Spill (مواد خطرة), Facility Evacuation (إخلاء).
- **Automated Event Dispatching:** Once confirmed via double-tap safety interlock:
  1. Opens WebSocket audio/visual broadcast sirens on all online safety personnel devices within the tenant zone.
  2. Creates an immutable `Incident Report` automatically stamping exact UTC timestamp, reporter credentials, mobile GPS geolocation or indoor layout markers, audio voice clips, videos, and corrective actions taken.
  3. Prepares architecture for future standardized API hooks into official national municipal dispatch services or third-party alerting sirens without forcing blind automatic external calling.

### 3.6 Offline-First Sync & Storage Mechanics
- All Core tasks—including asset lookups, form submissions, image capturing, task state transitions, and incident logging—persist directly to a local encrypted relational store (**SQLite / Isar**).
- When operating disconnected, local modifications receive UUIDs and sequential client transaction IDs (`tx_seq`). 
- Upon connection restoration, an background worker initiates a synchronized two-way negotiation:
  1. Uploads offline mutations via batch payload to `/api/sync/push`.
  2. Resolves server delta conflicts via deterministic rules (last-writer-wins with historical retention).
  3. Pulls latest layout updates, chat messages, and task distributions from `/api/sync/pull`.

### 3.7 Artificial Intelligence Safety Analytics Module
- **Computer Vision Hazard Detection:** Analyzing uploaded field photos for missing PPE (helmets, safety vests), obstructed exit paths, or corroded pressure valves.
- **Executive Incident Narrative Summarization:** Processing lengthy audio voice transcripts and scattered notes from emergency reports into cohesive executive bullet-point briefings and root cause hypotheses.
- **CAPA Advisory Engine:** Proactively suggesting standard Corrective and Preventive Actions based on industry regulations and historical remediation patterns.
- **Risk Assessment Scoring:** Computing dynamic heatmap danger multipliers across facility layouts by intersecting expired equipment counts with past incident frequency.
- **Semantic Safety Document Search:** Enabling natural language search ("What is the neutralizing agent for sulfuric acid burns?") across uploaded MSDS and corporate SOP documents.

---

## 4. Non-Functional Requirements (NFRs)
- **Scalability:** Horizontal scaling using Kubernetes HPA (Horizontal Pod Autoscaling) managing NestJS stateless workers and PostgreSQL reading replicas.
- **Security & Tenancy Zero-Trust:** Every database request MUST pass through tenant isolation guards enforcing `WHERE tenant_id = $curr_tenant`. All traffic encrypted via TLS 1.3 in transit and AES-256-GCM at rest.
- **Audit Immutability:** Audit records are generated directly at the database architectural boundary (append-only table with revoked DELETE/UPDATE SQL user grants).
- **UI/UX Performance:** Flutter frontend mandated to run at smooth 60/120 FPS on mobile hardware using asynchronous image caching and vector SVG graphics. Glassmorphism blur shaders optimized via FragmentShaders.
