import {
  CallHandler,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, from } from 'rxjs';
import { PrismaWriteProvider } from 'src/providers/prisma/prisma-write.provider';

@Injectable()
export class InjectUserInterceptor implements NestInterceptor {
  constructor(private readonly prismaWriteProvider: PrismaWriteProvider) {}

  async intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Promise<Observable<any>> {
    const request = context.switchToHttp().getRequest();
    const currentRoute = request.route?.path ?? '';

    const routesPublicByPassInterptor = ['/auth/login', '/auth/register'];

    const shouldBypass = routesPublicByPassInterptor.some(
      (route) => route === currentRoute,
    );
    if (shouldBypass) return next.handle();

    const payload = request.user;
    if (!payload?.userId) {
      console.warn('⚠️ Payload invalid in interceptor');
      return next.handle();
    }

    try {
      const user = await this.prismaWriteProvider.user.findUnique({
        where: { id: payload.userId },
      });

      if (!user.isActive) {
        throw new ForbiddenException('Access denied. User blocked');
      }

      request.userLogged = user;
      return from(next.handle());
    } catch (error) {
      console.error('❌ Error in InjectUserInterceptor:', error);
      throw new ForbiddenException('Access denied. User not found');
    }
  }
}
