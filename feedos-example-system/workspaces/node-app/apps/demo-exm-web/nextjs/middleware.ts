import createMiddleware from 'next-intl/middleware';
import { routing } from './i18n/routing';

export default createMiddleware(routing);

export const config = {
  // Match only internationalized pathnames
  matcher: [
    '/',
    '/(th|en)/:path*',
    '/((?!api|_next/static|_next/image|favicon.ico|sitemap.xml|robots.txt|error-failed|ssofoslogin|hello).*)',
    // '/((?!_next|_vercel|ssofoslogin|.*\\..*).*)',
  ],
};
