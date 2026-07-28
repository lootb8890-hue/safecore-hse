import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface AuthenticatedUser {
  id: string;
  email: string;
  role: 'ADMIN' | 'MEMBER';
  tenantId: string;
}

export const CurrentUser = createParamDecorator(
  (data: keyof AuthenticatedUser | undefined, ctx: ExecutionContext): any => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as AuthenticatedUser;
    if (!user) {
      return null;
    }
    return data ? user[data] : user;
  },
);
