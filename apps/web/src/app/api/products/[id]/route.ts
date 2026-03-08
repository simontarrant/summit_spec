import { NextRequest, NextResponse } from "next/server";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  // Database removed - return 404
  return NextResponse.json(
    { error: "Product not found" },
    { status: 404 }
  );
}
