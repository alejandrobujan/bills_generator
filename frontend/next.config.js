/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: `http://${process.env.API_HOST}:4000/api/:path*`,
      },
    ];
  },
};

module.exports = nextConfig;
