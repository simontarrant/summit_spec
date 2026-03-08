import { describe, it, expect, afterAll, vi } from "vitest";
import { prisma, disconnectDB } from "../setup/db";

vi.mock("@/lib/prisma", async () => {
  const { prisma } = await import("../setup/db");
  return { default: prisma };
});

import { GET } from "@/app/api/health/route";

afterAll(async () => {
  await disconnectDB();
});

describe("GET /api/health", () => {
  it("returns healthy status with database connected", async () => {
    const req = new Request("http://localhost/api/health");
    const res = await GET(req);
    const body = await res.json();

    expect(res.status).toBe(200);
    expect(body.status).toBe("healthy");
    expect(body.database).toBe("connected");
  });
});
