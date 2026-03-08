"use client";

import { useSession, signOut } from "next-auth/react";
import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";

export function AuthShell({ children }: { children: React.ReactNode }) {
  const { data: session, status } = useSession();
  const router = useRouter();
  const pathname = usePathname();

  // Don't show shell on login page
  if (pathname === "/login") {
    return <>{children}</>;
  }

  const handleSignOut = async () => {
    await signOut({ redirect: false });
    router.push("/login");
    router.refresh();
  };

  // Show loading state while checking auth
  if (status === "loading") {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-charcoal">Loading...</div>
      </div>
    );
  }

  // If not authenticated, don't show shell (middleware will redirect)
  if (!session) {
    return <>{children}</>;
  }

  return (
    <div className="ui-shell">
      {/* Top bar */}
      <header className="ui-topbar">
        <div className="ui-topbar-left">
          <div className="ui-logo-mark">⛰️</div>
          <div className="ui-logo-text">Gear Garage</div>
        </div>
        <div className="ui-topbar-right">
          <a
            href="https://www.wildernessaustralia.org.au/"
            className="ui-topbar-link ui-topbar-charity"
          >
            Support Trail Conservation
          </a>
          <button
            onClick={handleSignOut}
            className="ui-topbar-link ui-topbar-signout"
          >
            Sign out
          </button>
        </div>
      </header>

      {/* Tabs bar */}
      <nav className="ui-tabbar">
        <Link
          href="/example"
          className={`ui-tab ${pathname === "/example" ? "ui-tab-active" : ""}`}
        >
          Example
        </Link>
        <Link
          href="/products"
          className={`ui-tab ${
            pathname.startsWith("/products") ? "ui-tab-active" : ""
          }`}
        >
          Products
        </Link>
      </nav>

      {/* Page content */}
      {children}
    </div>
  );
}
