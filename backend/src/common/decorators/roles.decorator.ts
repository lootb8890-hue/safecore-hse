import { SetMetadata } from '@nestjs/common';

export type AllowedRole = 'ADMIN' | 'MEMBER';
export const ROLES_KEY = 'roles';
export const Roles = (...roles: AllowedRole[]) => SetMetadata(ROLES_KEY, roles);
