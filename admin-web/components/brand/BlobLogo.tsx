import Image from "next/image";
import { cn } from "@/lib/utils";

interface BlobLogoProps {
  size?: number;
  className?: string;
}

/**
 * BlobLogo — renders the official ZEST app icon.
 * Uses the real PNG asset from /public/zest_app_icon.png.
 * The `size` prop controls both width and height in px.
 */
export function BlobLogo({ size = 40, className = "" }: BlobLogoProps) {
  return (
    <Image
      src="/zest_app_icon.png"
      alt="ZEST logo"
      width={size}
      height={size}
      className={cn("rounded-[22%] object-cover shrink-0", className)}
      priority
    />
  );
}
