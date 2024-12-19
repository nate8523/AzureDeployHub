/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone', // Use "standalone" if you're optimizing for serverless or containerized deployments
  distDir: 'out',       // Use "out" as the build output directory
};

module.exports = nextConfig;
