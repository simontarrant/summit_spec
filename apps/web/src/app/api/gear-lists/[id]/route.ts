import { NextRequest, NextResponse } from "next/server";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  // Database removed - return 404
  return NextResponse.json(
    { error: "Gear list not found" },
    { status: 404 }
  );
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  // Database removed - return 404
  return NextResponse.json(
    { error: "Gear list not found" },
    { status: 404 }
  );
}
