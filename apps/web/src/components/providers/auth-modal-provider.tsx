"use client";

import React, { createContext, useContext, useState, useCallback } from "react";
import { usePathname } from "next/navigation";

interface AuthModalContextType {
  isOpen: boolean;
  openModal: (returnUrl?: string) => void;
  closeModal: () => void;
  returnUrl: string | null;
  clearReturnUrl: () => void;
}

const AuthModalContext = createContext<AuthModalContextType | undefined>(
  undefined
);

export function AuthModalProvider({ children }: { children: React.ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);
  const [returnUrl, setReturnUrl] = useState<string | null>(null);
  const pathname = usePathname();

  const openModal = useCallback(
    (customReturnUrl?: string) => {
      // Use custom return URL if provided, otherwise use current pathname
      setReturnUrl(customReturnUrl || pathname);
      setIsOpen(true);
    },
    [pathname]
  );

  const closeModal = useCallback(() => {
    setIsOpen(false);
  }, []);

  const clearReturnUrl = useCallback(() => {
    setReturnUrl(null);
  }, []);

  return (
    <AuthModalContext.Provider
      value={{ isOpen, openModal, closeModal, returnUrl, clearReturnUrl }}
    >
      {children}
    </AuthModalContext.Provider>
  );
}

export function useAuthModal() {
  const context = useContext(AuthModalContext);
  if (context === undefined) {
    throw new Error("useAuthModal must be used within an AuthModalProvider");
  }
  return context;
}
