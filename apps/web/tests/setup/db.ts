import { PrismaClient } from "@prisma/client";

export const prisma = new PrismaClient();

export async function resetDB() {
  const tables = await prisma.$queryRaw<
    { tablename: string }[]
  >`SELECT tablename FROM pg_tables WHERE schemaname = 'public'`;

  for (const { tablename } of tables) {
    if (tablename !== "goose_db_version") {
      await prisma.$executeRawUnsafe(
        `TRUNCATE TABLE "${tablename}" CASCADE`
      );
    }
  }
}

export async function disconnectDB() {
  await prisma.$disconnect();
}
