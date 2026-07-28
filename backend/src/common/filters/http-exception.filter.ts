import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger('EnterpriseExceptionHandler');

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const errorResponse =
      exception instanceof HttpException
        ? exception.getResponse()
        : { message: (exception as Error)?.message || 'Internal Enterprise Exception' };

    const message =
      typeof errorResponse === 'string'
        ? errorResponse
        : (errorResponse as any).message || errorResponse;

    if (status === HttpStatus.INTERNAL_SERVER_ERROR) {
      this.logger.error(`[500 Internal Error] ${request.method} ${request.url}`, (exception as Error)?.stack);
    } else {
      this.logger.warn(`[${status}] ${request.method} ${request.url} -> ${JSON.stringify(message)}`);
    }

    response.status(status).json({
      success: false,
      timestamp: new Date().toISOString(),
      path: request.url,
      statusCode: status,
      error: message,
    });
  }
}
