"use client";

import { useState, useRef, useLayoutEffect } from "react";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { Modal, ModalHeader, ModalBody } from "@/components/ui/modal";
import { SectionLabel } from "@/components/ui/card";
import { TextInput } from "@/components/ui/input";
import { PrimaryButton, AccentButton } from "@/components/ui/button";
import { cn } from "@/lib/cn";
import { useAuthModal } from "@/components/providers/auth-modal-provider";

type TabType = "login" | "signup";

export function LoginSignupModal() {
  const { isOpen, closeModal, returnUrl, clearReturnUrl } = useAuthModal();
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<TabType>("login");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // Height animation container + form element refs
  const wrapperRef = useRef<HTMLDivElement>(null);
  const loginRef = useRef<HTMLDivElement>(null);
  const signupRef = useRef<HTMLDivElement>(null);

  // Smooth height animation
  useLayoutEffect(() => {
    const wrapper = wrapperRef.current;
    if (!wrapper) return;

    const activeEl =
      activeTab === "login" ? loginRef.current : signupRef.current;

    if (!activeEl) return;

    const targetHeight = activeEl.scrollHeight;

    // Trigger layout flush
    void wrapper.offsetHeight;

    wrapper.style.height = `${targetHeight}px`;
  }, [activeTab, error]);

  // Form state
  const [loginIdentifier, setLoginIdentifier] = useState("");
  const [loginPassword, setLoginPassword] = useState("");

  const [signupUsername, setSignupUsername] = useState("");
  const [signupEmail, setSignupEmail] = useState("");
  const [signupPassword, setSignupPassword] = useState("");
  const [signupConfirmPassword, setSignupConfirmPassword] = useState("");

  const handleClose = () => {
    if (!loading) {
      closeModal();
      // Reset form state
      setActiveTab("login");
      setError(null);
      setLoginIdentifier("");
      setLoginPassword("");
      setSignupUsername("");
      setSignupEmail("");
      setSignupPassword("");
      setSignupConfirmPassword("");
    }
  };

  const handleSuccessfulAuth = () => {
    handleClose();
    // Redirect to return URL or refresh current page
    if (returnUrl) {
      router.push(returnUrl);
      clearReturnUrl();
    } else {
      router.refresh();
    }
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const result = await signIn("credentials", {
        identifier: loginIdentifier,
        password: loginPassword,
        redirect: false,
      });

      if (result?.error) {
        setError("Invalid username/email or password");
      } else if (result?.ok) {
        handleSuccessfulAuth();
      }
    } finally {
      setLoading(false);
    }
  };

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (signupPassword !== signupConfirmPassword) {
      setError("Passwords do not match");
      return;
    }

    if (signupPassword.length < 8) {
      setError("Password must be at least 8 characters long");
      return;
    }

    setLoading(true);

    try {
      const response = await fetch("/api/signup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          username: signupUsername,
          email: signupEmail,
          password: signupPassword,
        }),
      });

      const data = await response.json();
      if (!response.ok) {
        setError(data.error || "Signup failed");
        return;
      }

      const result = await signIn("credentials", {
        identifier: signupUsername,
        password: signupPassword,
        redirect: false,
      });

      if (result?.ok) {
        handleSuccessfulAuth();
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={handleClose}>
      <ModalHeader onClose={handleClose}>
        <div>
          <SectionLabel>Welcome</SectionLabel>
          <h2 className="mt-1">Hiking Gear</h2>
        </div>
      </ModalHeader>

      <ModalBody>
        <p className="text-slate mb-6">
          Manage your gear lists and track your hiking equipment.
        </p>

        {/* Tabs */}
        <div className="flex gap-2 border-b border-grey-200">
          <button
            onClick={() => {
              setActiveTab("login");
              setError(null);
            }}
            className={cn(
              "pb-2 px-4 font-medium transition-colors cursor-pointer",
              activeTab === "login"
                ? "text-primary border-b-2 border-primary"
                : "text-slate hover:text-charcoal"
            )}
          >
            Log In
          </button>
          <button
            onClick={() => {
              setActiveTab("signup");
              setError(null);
            }}
            className={cn(
              "pb-2 px-4 font-medium transition-colors cursor-pointer",
              activeTab === "signup"
                ? "text-primary border-b-2 border-primary"
                : "text-slate hover:text-charcoal"
            )}
          >
            Sign Up
          </button>
        </div>

        {/* Error */}
        {error && (
          <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded text-red-700 text-sm">
            {error}
          </div>
        )}

        {/* Height-animated wrapper */}
        <div
          ref={wrapperRef}
          className="relative transition-[height] duration-300 ease-in-out"
        >
          {/* LOGIN FORM */}
          <div
            ref={loginRef}
            className={cn(
              "transition-opacity duration-300",
              activeTab !== "login" &&
                "opacity-0 pointer-events-none absolute inset-0"
            )}
          >
            <form onSubmit={handleLogin} className="mt-6 space-y-4">
              <div>
                <label className="block mb-1 text-charcoal font-medium">
                  Username or Email
                </label>
                <TextInput
                  type="text"
                  value={loginIdentifier}
                  onChange={(e) => setLoginIdentifier(e.target.value)}
                  placeholder="Enter your username or email"
                  required
                  disabled={loading}
                  className="w-full"
                />
              </div>

              <div>
                <label className="block mb-1 text-charcoal font-medium">
                  Password
                </label>
                <TextInput
                  type="password"
                  value={loginPassword}
                  onChange={(e) => setLoginPassword(e.target.value)}
                  placeholder="Enter your password"
                  required
                  disabled={loading}
                  className="w-full"
                />
              </div>

              <PrimaryButton className="w-full mt-2" disabled={loading}>
                {loading ? "Logging in..." : "Log In"}
              </PrimaryButton>
            </form>
          </div>

          {/* SIGNUP FORM */}
          <div
            ref={signupRef}
            className={cn(
              "transition-opacity duration-300",
              activeTab !== "signup" &&
                "opacity-0 pointer-events-none absolute inset-0"
            )}
          >
            <form onSubmit={handleSignup} className="mt-6 space-y-4">
              <div>
                <label className="block mb-1 text-charcoal font-medium">
                  Username
                </label>
                <TextInput
                  type="text"
                  value={signupUsername}
                  onChange={(e) => setSignupUsername(e.target.value)}
                  placeholder="Choose a username"
                  required
                  disabled={loading}
                  className="w-full"
                />
              </div>

              <div>
                <label className="block mb-1 text-charcoal font-medium">
                  Email
                </label>
                <TextInput
                  type="email"
                  value={signupEmail}
                  onChange={(e) => setSignupEmail(e.target.value)}
                  placeholder="Enter your email"
                  required
                  disabled={loading}
                  className="w-full"
                />
              </div>

              <div>
                <label className="block mb-1 text-charcoal font-medium">
                  Password
                </label>
                <TextInput
                  type="password"
                  value={signupPassword}
                  onChange={(e) => setSignupPassword(e.target.value)}
                  placeholder="Choose a password"
                  required
                  disabled={loading}
                  className="w-full"
                />
              </div>

              <div>
                <label className="block mb-1 text-charcoal font-medium">
                  Confirm Password
                </label>
                <TextInput
                  type="password"
                  value={signupConfirmPassword}
                  onChange={(e) => setSignupConfirmPassword(e.target.value)}
                  placeholder="Re-enter your password"
                  required
                  disabled={loading}
                  className="w-full"
                />
              </div>

              <AccentButton className="w-full mt-2" disabled={loading}>
                {loading ? "Creating account..." : "Sign Up"}
              </AccentButton>
            </form>
          </div>
        </div>
      </ModalBody>
    </Modal>
  );
}
