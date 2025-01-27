interface TypeConfig {
    PSC_API: string;
    FEED_PORTAL_ICON: string;
    SPRINGBOOT_API: string;
    PORTAL_GETME: string;
    PORTAL_WEB: string;
    PORTAL_RENEW_TOKEN: string;
    INTERVAL: string;
    FOS_WEB: string;
    FOS_REPORT_STATIC_WEB: string;
    PSC_REPORT_API: string;
    PORTAL_API: string;
    PORTAL_VERIFY: string;
    API_TIMEOUT: string;
    BLOCK_ROUTE: string;
    GTM_ID: string;
    CMS_WEB_ADMIN_API: string
    ID_BI: string
  }
  
  let CONFIG: TypeConfig = {
    PSC_API: '',
    FEED_PORTAL_ICON: '',
    SPRINGBOOT_API: '',
    PORTAL_GETME: '',
    PORTAL_WEB: '',
    PORTAL_RENEW_TOKEN: '',
    INTERVAL: '',
    FOS_WEB: '',
    FOS_REPORT_STATIC_WEB: '',
    PSC_REPORT_API: '',
    PORTAL_API: '',
    PORTAL_VERIFY: '',
    API_TIMEOUT: '',
    BLOCK_ROUTE: 'true',
    GTM_ID: '',
    CMS_WEB_ADMIN_API: '',
    ID_BI: ''
  };
  
  if (process.env.NODE_ENV === 'production') {
    console.log('CONFIG_PRD');
    CONFIG = {
      PSC_API: '$NEXT_PUBLIC_PSC_API',
      FEED_PORTAL_ICON: '$NEXT_PUBLIC_FEED_PORTAL_ICON',
      SPRINGBOOT_API: '$NEXT_PUBLIC_SPRINGBOOT_API',
      PORTAL_GETME: `$NEXT_PUBLIC_PORTAL_GETME`,
      PORTAL_WEB: `$NEXT_PUBLIC_PORTAL_WEB`,
      PORTAL_RENEW_TOKEN: `$NEXT_PUBLIC_PORTAL_RENEW_TOKEN`,
      INTERVAL: `$NEXT_PUBLIC_INTERVAL`,
      FOS_WEB: `$NEXT_PUBLIC_FOS_WEB`,
      FOS_REPORT_STATIC_WEB: `$NEXT_PUBLIC_FOS_REPORT_STATIC_WEB`,
      PSC_REPORT_API: `$NEXT_PUBLIC_PSC_REPORT_API`,
      PORTAL_API: `$NEXT_PUBLIC_PORTAL_API`,
      PORTAL_VERIFY: `$NEXT_PUBLIC_PORTAL_VERIFY`,
      API_TIMEOUT: `$NEXT_PUBLIC_API_TIMEOUT`,
      BLOCK_ROUTE: `$NEXT_PUBLIC_BLOCK_ROUTE`,
      GTM_ID: `$NEXT_PUBLIC_GTM_ID`,
      CMS_WEB_ADMIN_API: `$NEXT_PUBLIC_CMS_WEB_URL`,
      ID_BI: `$NEXT_PUBLIC_ID_BI`,
    };
  } else {
    CONFIG = {
      PSC_API: `${process.env.NEXT_PUBLIC_PSC_API}`,
      FEED_PORTAL_ICON: `${process.env.NEXT_PUBLIC_FEED_PORTAL_ICON}`,
      SPRINGBOOT_API: `${process.env.NEXT_PUBLIC_SPRINGBOOT_API}`,
      PORTAL_GETME: `${process.env.NEXT_PUBLIC_PORTAL_GETME}`,
      PORTAL_WEB: `${process.env.NEXT_PUBLIC_PORTAL_WEB}`,
      PORTAL_RENEW_TOKEN: `${process.env.NEXT_PUBLIC_PORTAL_RENEW_TOKEN}`,
      INTERVAL: `${process.env.NEXT_PUBLIC_INTERVAL}`,
      FOS_WEB: `${process.env.NEXT_PUBLIC_FOS_WEB}`,
      FOS_REPORT_STATIC_WEB: `${process.env.NEXT_PUBLIC_FOS_REPORT_STATIC_WEB}`,
      PSC_REPORT_API: `${process.env.NEXT_PUBLIC_PSC_REPORT_API}`,
      PORTAL_API: `${process.env.NEXT_PUBLIC_PORTAL_API}`,
      PORTAL_VERIFY: `${process.env.NEXT_PUBLIC_PORTAL_VERIFY}`,
      API_TIMEOUT: `${process.env.NEXT_PUBLIC_API_TIMEOUT}`,
      BLOCK_ROUTE: `${process.env.NEXT_PUBLIC_BLOCK_ROUTE}`,
      GTM_ID: `${process.env.NEXT_PUBLIC_GTM_ID}`,
      CMS_WEB_ADMIN_API: `${process.env.NEXT_PUBLIC_CMS_WEB_URL}`,
      ID_BI: `${process.env.NEXT_PUBLIC_ID_BI}`
    };
  }
  export default CONFIG;
  