# SafeCore HSE Platform - API & WebSocket Documentation

This specification covers the comprehensive REST API and Real-time WebSocket (Socket.io) interaction model for **SafeCore HSE Platform**. All endpoints incorporate multi-tenant white-label isolation via bearer token extraction and header injection (`X-Tenant-ID`).

---

## 1. Authentication & Tenant Identity (`/api/v1/auth`)

### `POST /api/v1/auth/login`
Authenticates a user and returns JWT Bearer tokens alongside complete Tenant Branding parameters for rapid white-label interface rendering without secondary calls.
- **Request Body:**
```json
{
  "email": "inspector@enterprise-partner.com",
  "password": "SecurePassword123!",
  "client_device_id": "mob-9811-device-uid"
}
```
- **Response `200 OK`:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "def5020059c381fa0e211e4f3a...",
  "expires_in": 3600,
  "user": {
    "id": "usr_991823",
    "email": "inspector@enterprise-partner.com",
    "full_name": "Eng. Tariq Al-Mansoor",
    "role": "MEMBER",
    "avatar_url": "https://storage.safecore.io/tenants/t_1/avatars/tariq.jpg"
  },
  "tenant_branding": {
    "id": "t_101",
    "name": "Al-Basateen Petroleum Corp",
    "logo_url": "https://storage.safecore.io/tenants/t_1/logo.png",
    "primary_color": "#1A56DB",
    "secondary_color": "#0E317A",
    "accent_color": "#F05252",
    "font_family": "IBM Plex Sans Arabic",
    "is_rtl": true
  }
}
```

---

## 2. Interactive Facility Layouts (`/api/v1/layouts`)

### `POST /api/v1/layouts` *(Admin Only)*
Uploads a blueprint graphic file (PDF, PNG, JPG, DWG) and initializes an interactive map canvas.
- **Headers:** `Authorization: Bearer <Token>` | `Content-Type: multipart/form-data`
- **Parameters:** `name`, `branch_id`, `width_meters`, `height_meters`, `file (Binary)`

### `GET /api/v1/layouts/:id/canvas`
Returns interactive dimensions and array of pinned safety assets filtered by optional layer parameter.
- **Query Params:** `layer=EXTINGUISHER,EMERGENCY_EXIT,CAMERA`

---

## 3. Digital Safety Assets & QR Engine (`/api/v1/assets`)

### `POST /api/v1/assets` *(Admin / Member)*
Registers a new safety asset and automatically provisions QR codes, linear barcodes, and ready-to-print vector PDF adhesive labels.
- **Request Body:**
```json
{
  "name": "Powder Fire Extinguisher 6kg - Zone A",
  "asset_number": "EXT-ZN-A-0089",
  "layer_type": "EXTINGUISHER",
  "layout_id": "lay_551",
  "coord_x": 412.50,
  "coord_y": 189.20,
  "manufacturer": "FireDefense Ltd",
  "installation_date": "2025-01-10T00:00:00Z",
  "inspection_schedule": "MONTHLY"
}
```
- **Response `201 Created`:**
```json
{
  "id": "ast_7721",
  "asset_number": "EXT-ZN-A-0089",
  "qr_code_url": "https://storage.safecore.io/qrs/ast_7721.svg",
  "barcode": "10098221921",
  "printable_label_pdf": "https://api.safecore.io/v1/assets/ast_7721/label-download.pdf",
  "status": "ACTIVE"
}
```

### `GET /api/v1/assets/scan/:qr_payload`
Resolves a scanned QR string or Barcode directly into complete asset lifecycle history, latest inspection records, and open work tasks.

---

## 4. Inspection Form Engine (`/api/v1/inspections`)

### `POST /api/v1/inspections/forms` *(Admin Only - Form Builder)*
Creates an automated, schedule-driven dynamic inspection form without code.
- **Request Body Payload Example:**
```json
{
  "title": "Monthly Fire Extinguisher Compliance Check",
  "schedule_type": "MONTHLY",
  "target_layer_type": "EXTINGUISHER",
  "fields": [
    { "id": "f_1", "label": "Pressure Gauge in Green Zone?", "type": "BOOLEAN", "required": true },
    { "id": "f_2", "label": "Physical Damage or Rust?", "type": "BOOLEAN", "required": true },
    { "id": "f_3", "label": "Upload Photo of Tag & Extinguisher", "type": "IMAGE_CAMERA", "required": true },
    { "id": "f_4", "label": "Inspector Signature", "type": "SIGNATURE", "required": true },
    { "id": "f_5", "label": "GPS Coordinates", "type": "GPS_LOCATION", "required": true }
  ]
}
```

---

## 5. Offline-First Delta Synchronization (`/api/v1/sync`)

### `POST /api/v1/sync/push`
Receives a batch of local client mutations generated during offline execution in the field.
- **Request Body:**
```json
{
  "client_id": "mob-9811-device-uid",
  "last_synced_at": "2026-07-26T14:00:00Z",
  "mutations": [
    {
      "tx_id": "uuid-client-tx-01",
      "entity": "INSPECTION_RECORD",
      "action": "CREATE",
      "payload": { "form_id": "frm_01", "asset_id": "ast_7721", "answers": "..." },
      "client_timestamp": "2026-07-27T10:15:22Z"
    }
  ]
}
```

### `GET /api/v1/sync/pull?since=2026-07-26T14:00:00Z`
Returns delta JSON objects representing newly created or updated tasks, chats, layout additions, and emergency incidents across the tenant workspace since the timestamp.

---

## 6. Artificial Intelligence Safety Endpoints (`/api/v1/ai`)

### `POST /api/v1/ai/analyze-hazard-photo`
Accepts a binary field camera photograph and returns confidence bounding boxes of detected HSE violations (e.g. absent helmets, unanchored ladders, obstructed fire hose boxes).

### `POST /api/v1/ai/summarize-incident`
Synthesizes multi-paragraph field investigation logs and audio transcriptions into structured executive CAPA (Corrective and Preventive Action) advice.

---

## 7. Real-Time WebSockets Architecture (Socket.io Namespace: `/hse`)

All WebSocket connections authenticate via JWT handshake query parameters:
`wss://api.safecore.io/hse?token=eyJhbGciOiJIUz...`

### Server-to-Client Broadcast Events:
1. **`EMERGENCY_SIREN_TRIGGERED`**
   - Broadcast to every active device under the same `tenant_id`.
   - **Payload:**
   ```json
   {
     "incident_id": "inc_9901",
     "type": "FIRE",
     "severity": "CRITICAL",
     "reported_by_name": "Ahmed K. (Safety Supervisor)",
     "location_text": "Refinery Zone 4 - Boiler Shed B",
     "coord_x": 841.0,
     "coord_y": 210.3,
     "timestamp": "2026-07-27T14:59:00Z",
     "siren_sound_pattern": "CONTINUOUS_ALARM_1"
   }
   ```
2. **`CHAT_MESSAGE_RECEIVED`**
   - Immediate delivery of encrypted internal safety group discussions, image notes, and Voice-over-IP audio snippets.
3. **`TASK_ASSIGNMENT_NOTIFY`**
   - Alerts safety officers upon receipt of urgent daily inspection assignments or hazard remediation tasks.
