import React from "react";
import { Card } from "../components/ui/Card";
import {
  ClipboardList,
  Image as ImageIcon,
  Sparkles,
  ShieldCheck
} from "lucide-react";
import HeroVisual from "../components/HeroVisual";
import Background from "../components/Background";

import Logo from "../components/ui/Logo";

type Props = {
  children: React.ReactNode;
  title?: string;
  subtitle?: string;
  variant?: "default" | "simple";
};

export default function AuthLayout({ children, title, subtitle, variant = "default" }: Props) {
  const isSimple = variant === "simple";

  return (
    <div className="relative min-h-screen">
      <Background />
      <div className={`relative z-10 mx-auto max-w-7xl ${isSimple ? 'flex justify-center items-center min-h-screen' : 'grid grid-cols-1 xl:grid-cols-2'} gap-6 sm:gap-8 px-4 sm:px-6 lg:px-8 py-8 sm:py-12 lg:py-16`}>
        {!isSimple && (
          <div className="hidden lg:flex flex-col justify-center">
            <div className="rounded-xl bg-white/80 backdrop-blur-md border border-white/50 shadow-soft p-10 relative overflow-hidden">
              <div className="mb-8">
                <Logo size="lg" />
              </div>
              <h1 className="mt-6 text-3xl font-semibold text-gray-900">
                {title || "Accelerate your annotation workflow"}
              </h1>
              <p className="mt-3 text-gray-600">
                {subtitle ||
                  "Collaborate, annotate, and manage datasets with clarity and speed."}
              </p>
              <div className="absolute right-6 top-6 opacity-60">
                <HeroVisual />
              </div>
              <div className="mt-6 flex flex-wrap gap-3">
                <div className="inline-flex items-center rounded-xl bg-surface-soft border border-gray-100 px-3 h-9 text-sm text-gray-700 animate-fadeIn">
                  12k images labeled
                </div>
                <div className="inline-flex items-center rounded-xl bg-surface-soft border border-gray-100 px-3 h-9 text-sm text-gray-700 animate-fadeIn">
                  97% QA pass
                </div>
                <div className="inline-flex items-center rounded-xl bg-surface-soft border border-gray-100 px-3 h-9 text-sm text-gray-700 animate-fadeIn">
                  50+ annotators
                </div>
              </div>
              <div className="mt-8 grid grid-cols-2 gap-3 lg:gap-4">
                <Card variant="glass" className="p-4 h-24 sm:h-28 xl:h-32 flex flex-col items-center justify-center animate-float">
                  <div className="h-10 w-10 rounded-xl bg-blue-100 flex items-center justify-center">
                    <ClipboardList className="h-5 w-5 text-blue-600" />
                  </div>
                  <div className="mt-2 text-sm font-medium text-gray-900">Projects</div>
                  <div className="text-xs text-gray-600">Organize datasets</div>
                </Card>
                <Card variant="glass" className="p-4 h-24 sm:h-28 xl:h-32 flex flex-col items-center justify-center animate-float">
                  <div className="h-10 w-10 rounded-xl bg-indigo-100 flex items-center justify-center">
                    <ImageIcon className="h-5 w-5 text-indigo-600" />
                  </div>
                  <div className="mt-2 text-sm font-medium text-gray-900">Images</div>
                  <div className="text-xs text-gray-600">Preview samples</div>
                </Card>
                <Card variant="glass" className="p-4 h-24 sm:h-28 xl:h-32 flex flex-col items-center justify-center animate-float">
                  <div className="h-10 w-10 rounded-xl bg-teal-100 flex items-center justify-center">
                    <Sparkles className="h-5 w-5 text-teal-600" />
                  </div>
                  <div className="mt-2 text-sm font-medium text-gray-900">AI Assist</div>
                  <div className="text-xs text-gray-600">Speed up annotation</div>
                </Card>
                <Card variant="glass" className="p-4 h-24 sm:h-28 xl:h-32 flex flex-col items-center justify-center animate-float">
                  <div className="h-10 w-10 rounded-xl bg-gray-100 flex items-center justify-center">
                    <ShieldCheck className="h-5 w-5 text-gray-700" />
                  </div>
                  <div className="mt-2 text-sm font-medium text-gray-900">Quality</div>
                  <div className="text-xs text-gray-600">Review & QA</div>
                </Card>
              </div>
            </div>
          </div>
        )}
        <div className={`flex flex-col items-center justify-center px-0 sm:px-4 ${isSimple ? 'w-full max-w-lg' : ''}`}>
          {isSimple && (
            <div className="mb-8 scale-110">
              <Logo size="lg" showSlogan={false} />
            </div>
          )}
          {children}
        </div>
      </div>
    </div>
  );
}
