import { describe, it, expect, beforeEach, afterAll } from "vitest";
import { prisma, resetDB, disconnectDB } from "../setup/db";

afterAll(async () => {
  await disconnectDB();
});

describe("brands integration", () => {
  beforeEach(async () => {
    await resetDB();
  });

  it("seeds a brand and queries it back", async () => {
    await prisma.brand.create({
      data: {
        slug: "nemo",
        name: "Nemo Equipment",
        country: "US",
      },
    });

    const brands = await prisma.brand.findMany();
    expect(brands).toHaveLength(1);
    expect(brands[0].name).toBe("Nemo Equipment");
  });

  it("resetDB clears data between tests", async () => {
    const brands = await prisma.brand.findMany();
    expect(brands).toHaveLength(0);
  });
});
