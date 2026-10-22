import { Module } from '@nestjs/common';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PlusAddressingModule } from './email/plus-addressing/plus-addresing.module.ts';

// Each feature receives its own route and its own module
@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      useFactory: () => ({
        type: 'better-sqlite3',
        database: 'data/db.sqlite',
        autoLoadEntities: true,
        synchronize: process.env.NODE_ENV === 'dev',
      }),
    }),
    PlusAddressingModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
