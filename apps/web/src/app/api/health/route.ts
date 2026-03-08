import { NextResponse } from "next/server";
import prisma from "@/lib/prisma";

export async function GET() {
  try {
    await prisma.$queryRaw`SELECT 1 as ok`;
    return NextResponse.json(
      { status: "healthy", database: "connected" },
      { status: 200 }
    );
  } catch {
    return NextResponse.json(
      { status: "unhealthy", database: "disconnected" },
      { status: 503 }
    );
  }
}
