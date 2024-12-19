/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export', // Ensures Next.js generates static files for export
  distDir: 'out'    // Forces Next.js to use the 'out' directory
};

module.exports = nextConfig;
