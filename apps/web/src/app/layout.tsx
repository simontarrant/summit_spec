// src/app/layout.tsx
import "./globals.css";
import { Inter, Sora, JetBrains_Mono } from "next/font/google";
import { SessionProvider } from "@/components/providers/session-provider";
import { AuthModalProvider } from "@/components/providers/auth-modal-provider";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

const sora = Sora({
  subsets: ["latin"],
  variable: "--font-sora",
  display: "swap",
});

const jetbrains = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
  display: "swap",
});

export const metadata = {
  title: "Hiking Gear",
  description: "Manage your gear lists and track your hiking equipment",
  icons: {
    icon: "/logo.svg",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${sora.variable} ${jetbrains.variable}`}
    >
      <body>
        <SessionProvider>
          <AuthModalProvider>{children}</AuthModalProvider>
        </SessionProvider>
      </body>
    </html>
  );
}
