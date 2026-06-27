/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Served behind nginx at /admin (the landing page owns "/").
  basePath: '/admin',
};

export default nextConfig;
