import { NextResponse } from "next/server";

export async function GET() {
  // Database removed - return empty products array
  return NextResponse.json({ products: [] }, { status: 200 });
}

export async function POST(request: Request) {
  // Database removed - return 501 Not Implemented
  return NextResponse.json(
    { error: "Product creation not available" },
    { status: 501 }
  );
}
