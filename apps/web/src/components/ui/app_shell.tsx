"use client";

import React from "react";
import { useSession, signOut } from "next-auth/react";
import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";
import { cn } from "@/lib/cn";
import { useAuthModal } from "@/components/providers/auth-modal-provider";
import { LoginSignupModal } from "@/components/ui/login-signup-modal";

type Tab = {
  label: string;
  href: string;
};

interface AppShellProps {
  children: React.ReactNode;
  tabs?: Tab[];
  pageTitle?: string;
  pageDescription?: string;
  titleAddon?: React.ReactNode;
  filterBar?: React.ReactNode;
}

export function AppShell({
  children,
  tabs,
  pageTitle,
  pageDescription,
  titleAddon,
  filterBar
}: AppShellProps) {
  return (
    <div className="ui-shell">
      <Topbar />
      {tabs && <Tabbar tabs={tabs} />}
      <div className="ui-content-container">
        {(pageTitle || pageDescription) && (
          <div className="ui-page-header">
            <div className="ui-page-header-top">
              {pageTitle && <h1 className="ui-page-title">{pageTitle}</h1>}
              {titleAddon && (
                <>
                  <span className="ui-page-title-sep">|</span>
                  <div className="ui-page-title-addon">{titleAddon}</div>
                </>
              )}
            </div>
            {pageDescription && <p className="ui-page-description">{pageDescription}</p>}
          </div>
        )}
        {filterBar && (
          <div className="ui-filter-bar">
            {filterBar}
          </div>
        )}
        {children}
      </div>
      <LoginSignupModal />
    </div>
  );
}

function Topbar() {
  const { data: session, status } = useSession();
  const router = useRouter();
  const { openModal } = useAuthModal();

  const handleSignOut = async () => {
    await signOut({ redirect: false });
    router.push("/example");
    router.refresh();
  };

  return (
    <header className="ui-topbar">
      <div className="ui-topbar-left">
        <div className="ui-logo-mark">⛰️</div>
        <div className="ui-logo-text">Summit Spec</div>
      </div>
      <div className="ui-topbar-right">
        <a
          href="https://www.wildernessaustralia.org.au/"
          className="ui-topbar-link ui-topbar-charity"
          target="_blank"
          rel="noopener noreferrer"
        >
          Support Trail Conservation
        </a>
        {status === "loading" ? (
          <div className="ui-topbar-link text-slate">...</div>
        ) : session ? (
          <button
            onClick={handleSignOut}
            className="ui-topbar-link ui-topbar-signout"
          >
            Sign out
          </button>
        ) : (
          <button
            onClick={() => openModal()}
            className="ui-topbar-link ui-topbar-signout"
          >
            Sign in
          </button>
        )}
      </div>
    </header>
  );
}

interface TabbarProps {
  tabs: Tab[];
}

function Tabbar({ tabs }: TabbarProps) {
  const pathname = usePathname();

  return (
    <nav className="ui-tabbar">
      {tabs.map((tab) => {
        const isActive =
          tab.href === "/example"
            ? pathname === "/example"
            : pathname.startsWith(tab.href);

        return (
          <Link
            key={tab.label}
            href={tab.href}
            className={cn("ui-tab", isActive && "ui-tab-active")}
          >
            {tab.label}
          </Link>
        );
      })}
    </nav>
  );
}
