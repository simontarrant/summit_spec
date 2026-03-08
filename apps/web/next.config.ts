import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  env: {
    AUTH_URL: process.env.AUTH_URL,
    AUTH_SECRET: process.env.AUTH_SECRET,
  },
};

export default nextConfig;
