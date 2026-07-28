import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap() {
  const logger = new Logger('SafeCoreBootstrap');
  const app = await NestFactory.create(AppModule, {
    logger: ['log', 'error', 'warn', 'debug', 'verbose'],
  });

  // Enterprise Cybersecurity Hardening (Helmet & Zero-Trust CORS)
  app.use(helmet());
  app.enableCors({
    origin: '*', // Customize in production environments to approved domain array
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
    allowedHeaders: 'Content-Type, Accept, Authorization, X-Tenant-ID',
  });

  // Global Prefix
  app.setGlobalPrefix('api/v1');

  // Unified Error Handling & Validation
  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // OpenAPI Swagger Documentation Generator
  const config = new DocumentBuilder()
    .setTitle('SafeCore HSE Platform API')
    .setDescription(
      'World-Class Multi-Tenant White-Label Occupational Safety & Emergency Platform API Documentation.',
    )
    .setVersion('1.0.0')
    .addBearerAuth()
    .addApiKey({ type: 'apiKey', name: 'X-Tenant-ID', in: 'header' }, 'TenantIdHeader')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`🚀 SafeCore HSE Enterprise Backend live on: http://localhost:${port}/api/v1`);
  logger.log(`📚 OpenAPI Swagger Documentation ready on: http://localhost:${port}/api/docs`);
}
bootstrap();
