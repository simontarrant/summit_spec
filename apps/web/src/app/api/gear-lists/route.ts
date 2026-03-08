import { NextRequest, NextResponse } from "next/server";

export async function GET() {
  // Database removed - return empty gear lists array
  return NextResponse.json({ gearLists: [] }, { status: 200 });
}

export async function POST(request: NextRequest) {
  // Database removed - return 501 Not Implemented
  return NextResponse.json(
    { error: "Gear list creation not available" },
    { status: 501 }
  );
}
