import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global() // Makes PrismaService available in all modules automatically
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}