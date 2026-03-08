import { describe, it, expect } from "vitest";

function add(a: number, b: number) {
  return a + b;
}

describe("math", () => {
  it("adds numbers", () => {
    expect(add(2, 3)).toBe(5);
  });
});
