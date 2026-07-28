import { PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting Enterprise SafeCore HSE Platform Database Seeding...');

  // 1. Create Enterprise Tenant: PetroApex Refinery (Oil & Gas)
  const petroTenant = await prisma.tenant.upsert({
    where: { subdomain: 'petroapex' },
    update: {},
    create: {
      name: 'PetroApex Energy & Refineries',
      subdomain: 'petroapex',
      logoUrl: 'https://safecore-assets.s3.amazonaws.com/logos/petroapex.png',
      primaryColor: '#1A365D', // Corporate Navy
      secondaryColor: '#DD6B20', // Industrial Safety Orange
      accentColor: '#38A169', // Compliance Green
      fontFamily: 'IBM Plex Sans Arabic',
      isRtl: false,
    },
  });

  // 2. Create Healthcare Tenant: Royal Al-Noor Medical City (Arabic RTL)
  const hospitalTenant = await prisma.tenant.upsert({
    where: { subdomain: 'alnoor' },
    update: {},
    create: {
      name: 'مدينة النور الطبية للصحة والسلامة',
      subdomain: 'alnoor',
      logoUrl: 'https://safecore-assets.s3.amazonaws.com/logos/alnoor_hospital.png',
      primaryColor: '#2B6CB0', // Medical Blue
      secondaryColor: '#E53E3E', // Alert Red
      accentColor: '#4FD1C5', // Teal
      fontFamily: 'IBM Plex Sans Arabic',
      isRtl: true,
    },
  });

  console.log('✅ Created Multi-Tenant Workspaces:', petroTenant.name, '&', hospitalTenant.name);

  // 3. Create Admin & Member users for PetroApex
  const defaultPassword = await argon2.hash('SafeCore@2026!');
  const adminUser = await prisma.user.upsert({
    where: { id: 'usr_admin_petro_01' },
    update: {},
    create: {
      id: 'usr_admin_petro_01',
      tenantId: petroTenant.id,
      email: 'admin@petroapex.com',
      passwordHash: defaultPassword,
      fullName: 'Eng. Khalid Al-Mansoor (HSE Director)',
      role: 'ADMIN',
      department: 'HSE Corporate Governance',
      branch: 'Jeddah Refinery Plant A',
    },
  });

  const fieldMember = await prisma.user.upsert({
    where: { id: 'usr_member_petro_02' },
    update: {},
    create: {
      id: 'usr_member_petro_02',
      tenantId: petroTenant.id,
      email: 'inspector@petroapex.com',
      passwordHash: defaultPassword,
      fullName: 'Tariq Ziad (Field Safety Inspector)',
      role: 'MEMBER',
      department: 'Field Operations',
      branch: 'Jeddah Refinery Plant A',
    },
  });

  console.log('✅ Provisioned Enterprise User Accounts (Admin & Field Member)');

  // 4. Create Interactive Facility Floor Plan
  const layout = await prisma.facilityLayout.create({
    data: {
      tenantId: petroTenant.id,
      name: 'Main Distillation Column & Control Room Floor Plan (Layer 1)',
      branchName: 'Plant A - Central Operations',
      fileUrl: 'https://safecore-assets.s3.amazonaws.com/blueprints/refinery_plant_a_floor1.png',
      fileType: 'PNG',
      widthMeters: 150.5,
      heightMeters: 95.2,
      canvasResX: 3500,
      canvasResY: 2400,
    },
  });

  // 5. Create Sample Safety Assets with automated QR Codes
  const ext1 = await prisma.safetyAsset.create({
    data: {
      tenantId: petroTenant.id,
      layoutId: layout.id,
      layerType: 'EXTINGUISHER',
      assetNumber: 'EXT-9901-A',
      name: 'Heavy Duty 50kg Foam Fire Extinguisher Unit',
      qrCode: `safecore://asset?id=EXT-9901-A&tenant=${petroTenant.id}`,
      barcode: '880192384752',
      status: 'ACTIVE',
      coordX: 1250,
      coordY: 640,
      manufacturer: 'Kidde Industrial Safety',
      installationDate: new Date('2025-01-10'),
    },
  });

  console.log('✅ Created Digital Twin Safety Asset & Placed on Canvas Coordinates');

  // 6. Create Dynamic Inspection Form
  const form = await prisma.inspectionForm.create({
    data: {
      tenantId: petroTenant.id,
      title: 'Weekly Industrial Fire Extinguisher Pressure & Seal Check',
      description: 'Standard NFPA compliance checklist for portable and wheeled industrial extinguishers.',
      targetLayer: 'EXTINGUISHER',
      scheduleFrequency: 'WEEKLY',
      formSchema: [
        { id: 'f_1', label: 'Is the pressure gauge needle resting in the green operational zone?', type: 'CHECKBOX', required: true },
        { id: 'f_2', label: 'Verify pin and tamper-evident plastic seal integrity', type: 'CHECKBOX', required: true },
        { id: 'f_3', label: 'Record current cylinder tank pressure readings (PSI)', type: 'NUMBER', required: true },
        { id: 'f_4', label: 'Capture photo of any rust or physical abrasion on nozzle', type: 'IMAGE_UPLOAD', required: false },
        { id: 'f_5', label: 'Inspector Digital Signature & Confirmation', type: 'SIGNATURE', required: true },
        { id: 'f_6', label: 'Verify inspector physical presence via GPS triangulation', type: 'GPS_CAPTURE', required: true },
      ] as any,
    },
  });

  console.log('✅ Created No-Code Dynamic Inspection Schema:', form.title);

  console.log('🎉 Seeding successfully completed! System ready for enterprise evaluation.');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
