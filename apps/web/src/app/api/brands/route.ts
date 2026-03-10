import { NextResponse } from "next/server";

export const preferredRegion = "syd1";

export async function GET() {
  // Database removed - return empty brands array
  return NextResponse.json({ brands: [] }, { status: 200 });
}
