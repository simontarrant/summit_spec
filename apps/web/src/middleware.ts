import { auth } from "@/lib/auth";
import { NextResponse } from "next/server";

export default auth((req) => {
  const { pathname } = req.nextUrl;
  const isAuthenticated = !!req.auth;

  // If someone tries to access /login, redirect to /example
  // (login is now a modal, not a page)
  if (pathname === "/login") {
    const exampleUrl = new URL("/example", req.url);
    return NextResponse.redirect(exampleUrl);
  }

  // All pages are now public - pages handle their own auth state
  // API routes should handle their own auth checks as needed
  return NextResponse.next();
});

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|public).*)"],
};
