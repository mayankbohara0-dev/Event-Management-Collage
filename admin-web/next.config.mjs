/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  compress: true,
  poweredByHeader: false,
  experimental: {
    // Tree-shake icon/animation packages — can cut 30-80kb from each page bundle
    optimizePackageImports: ["lucide-react", "framer-motion", "date-fns"],
  },
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "*.supabase.co",
      },
      {
        protocol: "https",
        hostname: "images.unsplash.com",
      },
    ],
    // Enable image optimization with aggressive caching
    minimumCacheTTL: 3600,
  },
};

export default nextConfig;
