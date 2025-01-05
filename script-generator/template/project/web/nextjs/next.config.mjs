import createNextIntlPlugin from 'next-intl/plugin';
const withNextIntl = createNextIntlPlugin();

/** @type {import('next').NextConfig} */
const nextConfig = {
    modularizeImports: {
        '@mui/material': {
          transform: '@mui/material/{{member}}',
        },
        '@mui/icons-material': {
          transform: '@mui/icons-material/{{member}}',
        },
      },
    images: {
        loader: "custom",
        loaderFile: './ImageLoader.js',
    },
    output: 'standalone',
    async headers() {
        return [
            {
                source: '/:path*',
                headers: [
                    {
                        key: 'Cache-Control',
                        value: 'no-cache, private',
                    },
                    {
                        key: 'Content-Security-Policy',
                        // value: `upgrade-insecure-requests; frame-ancestors=self; script-src=self; object-src=self; form-action=none;`,
                        value: `upgrade-insecure-requests; frame-ancestors 'self'`,
                    },
                    {
                        key: 'Strict-Transport-Security',
                        value: 'max-age=31536000; includeSubDomains; preload',
                    },
                    {
                        key: 'X-frame-options',
                        value: 'SAMEORIGIN',
                    },
                    {
                        key: 'X-content-type-options',
                        value: 'nosniff',
                    },
                    {
                        key: 'x-xss-protection',
                        value: '1;mode=block',
                    }
                ],
            },
            {
                source: '/app/main/prescription',
                headers: [
                    {
                        key: 'Cache-Control',
                        value: 'no-cache, private',
                    },
                    {
                        key: 'Content-Security-Policy',
                        // value: `upgrade-insecure-requests; frame-ancestors=self; script-src=self; object-src=self; form-action=none;`,
                        value: `upgrade-insecure-requests; frame-ancestors 'self'`,
                    },
                    {
                        key: 'Strict-Transport-Security',
                        value: 'max-age=31536000; includeSubDomains; preload',
                    },
                    {
                        key: 'X-frame-options',
                        value: 'SAMEORIGIN',
                    },
                    {
                        key: 'X-content-type-options',
                        value: 'nosniff',
                    },
                    {
                        key: 'x-xss-protection',
                        value: '1;mode=block',
                    }
                ],
            },
        ];
    },
    webpack: (
        config
      ) => {
        // Important: return the modified config
        config.module.rules.push({
          test: /\.node/,
          use: 'raw-loader',
        });
        return config;
    }
};

export default withNextIntl(nextConfig);
