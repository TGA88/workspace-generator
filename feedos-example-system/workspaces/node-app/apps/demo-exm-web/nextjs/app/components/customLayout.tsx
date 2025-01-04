'use client';
import React, { ReactNode } from 'react';
import { ThemeProvider } from '@mui/material';
import {
  Layout,
  ProtectedLayout,
  useManageLayout,
  useManageLayoutProps,
  theme,
} from '@feed-portalshared-system/ui-common';
import * as nextNavigate from 'next/navigation';
import CONFIG from '@fos-psc-web/config';
import { Provider } from 'react-redux';
import { store } from '@fos-psc-web/utils';
import { UserProfile } from '@fos-psc-web/feature-prescription';
import { useRouter, usePathname } from '../../i18n/routing';
import { useLocale } from 'next-intl';

interface Props {
  children: ReactNode;
}

export const CustomLayout = ({ children }: Props) => {
  const path = usePathname();
  const router = useRouter();
  const params = nextNavigate.useParams();
  const defaultLang = useLocale();
  const [isPending, startTransition] = React.useTransition();

  const settingManage: useManageLayoutProps = {
    url: CONFIG.PORTAL_GETME,
    baseApiurl: CONFIG.PORTAL_API,
    system: 'FEEDOS',
    backPortalurl: CONFIG.PORTAL_WEB,
    moduelCode: 'FEEDOSPSC',
  };

  const {
    profile,
    selectOrg,
    orgOption,
    selectRole,
    roleOption,
    moduelCode,
    moduelOption,
    routePathAction,
    handleClickedLogout,
    handleSelectOrg,
    handleSelectRole,
    handleOpen,
    openDialog,
    redirectToOtherSystem,
    blockManualRouting,
    permisionMenu,
  } = useManageLayout(settingManage);

  const langChange = (lang?: string) => {
    startTransition(() => {
      // @ts-expect-error -- TypeScript will validate that only known `params`
      router.replace({ pathname: path, params }, { locale: lang });
    });
  };

  return (
    <Provider store={store}>
      <ThemeProvider theme={theme}>
        <ProtectedLayout
          portalWebUrl={CONFIG.PORTAL_WEB}
          currentWebUrl={CONFIG.FOS_WEB}
          interval={CONFIG.INTERVAL}
          renewTokenApi={CONFIG.PORTAL_RENEW_TOKEN}
          openDialog={openDialog}
          removeDialog={false}
          selectOrg={selectOrg}
          selectRole={selectRole}
          orgOption={orgOption}
          roleOption={roleOption}
          handleOpenDialog={handleOpen}
          handleChangeOrg={handleSelectOrg}
          handleChangeRole={handleSelectRole}
          blockManualRoute={
            CONFIG.BLOCK_ROUTE === 'true'
              ? {
                action: blockManualRouting,
                currentPath: path,
                defaultPage: '/',
                menu: permisionMenu.includes('/prescription-report')
                  ? [...permisionMenu, '/download-csv', '/download-pdf', '/farm-info']
                  : undefined,
              }
              : undefined
          }
        >
          <UserProfile gtmId={CONFIG.GTM_ID} />
          <Layout
            imgPath={CONFIG.FEED_PORTAL_ICON}
            profile={profile}
            currentPath={path}
            selectOrg={selectOrg}
            orgOption={orgOption}
            selectRole={selectRole}
            RoleOption={roleOption}
            moduelCode={moduelCode}
            otherModule={moduelOption}
            goTo={routePathAction}
            onClickedLogout={handleClickedLogout}
            handleChangeOrg={handleSelectOrg}
            handleChangeRole={handleSelectRole}
            handleRedirectOther={(a) => redirectToOtherSystem(a, 'ssofoslogin')}
            isActive={true}
            systemName="Smart Prescription"
            desktopLogo={
              <svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clipPath="url(#clip0_2375_54956)">
                  <path
                    d="M34.2226 0H13.7857C6.18441 0 0 6.18418 0 13.781V34.2172C0 41.8182 6.18441 47.9982 13.7816 47.9982H34.2184C41.8198 47.9982 48 41.814 48 34.2172V13.781C48.0042 6.18418 41.8198 0 34.2226 0Z"
                    fill="url(#paint0_linear_2375_54956)"
                  />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M26.0769 48H34.2022C41.8035 48 47.9838 41.8158 47.9838 34.219V33.4037L33.5681 44.1662C31.242 45.9028 28.7072 47.1753 26.0769 48Z"
                    fill="#00964C"
                  />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M48 25.4457V34.2172C48 39.8185 44.6401 44.6519 39.828 46.8046C38.5506 46.126 37.4008 45.1639 36.4821 43.9335L23.9186 27.1062L11.355 43.9335C10.4543 45.1399 9.33127 46.0883 8.08372 46.7646C3.32027 44.5931 0 39.7866 0 34.2172V25.228L15.4365 4.55286C16.0654 3.59361 16.8682 2.7271 17.8374 2.00392C19.6491 0.65198 21.7756 1.80977e-06 23.8864 0H34.2226C41.8198 0 48.0042 6.18418 48 13.781V25.4457Z"
                    fill="url(#paint1_linear_2375_54956)"
                  />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M35.5509 42.6842L36.4848 43.935C37.4013 45.1627 38.5473 46.1226 39.8208 46.8014C44.6268 44.6459 47.9816 39.8161 47.9816 34.2189V33.4037L35.5509 42.6842Z"
                    fill="#22AB67"
                  />
                  <path d="M23.7784 25.4312H21.9896V27.22H23.7784V25.4312Z" fill="#F5FAFE" />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M13.7162 14.8354V14.1431H9.24417V18.7495C8.25291 20.3309 7.67981 22.201 7.67981 24.205C7.67981 29.8854 12.2847 34.4904 17.9652 34.4904C23.6457 34.4904 28.2505 29.8854 28.2505 24.205C28.2505 23.9379 28.2403 23.6733 28.2203 23.4114C29.2865 24.7147 30.9074 25.5465 32.7226 25.5465H34.9586C36.6875 25.5465 38.0891 26.948 38.0891 28.6769C38.0891 30.4057 36.6875 31.8073 34.9586 31.8073H26.9089V34.4904H34.9586C38.1694 34.4904 40.7723 31.8876 40.7723 28.6769C40.7723 25.4662 38.1694 22.8634 34.9586 22.8634H32.7226C30.9937 22.8634 29.5921 21.4619 29.5921 19.733C29.5921 18.0042 30.9937 16.6027 32.7226 16.6027H39.8779V13.9195H32.7226C29.7018 13.9195 27.2191 16.2233 26.9358 19.1697C25.1732 16.0362 21.8164 13.9195 17.9652 13.9195C16.45 13.9195 15.0114 14.2471 13.7162 14.8354ZM13.7162 17.9V21.7454H15.0579V18.1558L19.9772 20.839V18.1628L24.722 20.7176C23.458 18.2733 20.9066 16.6027 17.9652 16.6027C16.3914 16.6027 14.9293 17.0809 13.7162 17.9ZM25.3988 22.6057L21.3188 20.4089V23.099L16.3995 20.4158V23.087H12.3746V17.9442H10.5867V22.3673L10.5858 22.3708V26.0392C10.8976 27.298 11.5232 28.4331 12.3746 29.3566V25.3229H20.4244V31.4007C23.416 30.3785 25.5673 27.543 25.5673 24.205C25.5673 23.6564 25.5091 23.1213 25.3988 22.6057ZM15.9523 31.5379C15.1196 31.3098 14.3439 30.9437 13.6515 30.4657H13.7162V26.6645H15.9523V31.5379ZM17.0703 31.7551C17.3638 31.7896 17.6624 31.8073 17.9652 31.8073C18.3448 31.8073 18.718 31.7794 19.0827 31.7257V26.6645H17.0703V31.7551ZM12.3746 15.4847V16.6027H10.5858V15.4847H12.3746Z"
                    fill="#F5FAFE"
                  />
                </g>
                <defs>
                  <linearGradient
                    id="paint0_linear_2375_54956"
                    x1="46.752"
                    y1="41.375"
                    x2="2.72724"
                    y2="1.02179"
                    gradientUnits="userSpaceOnUse"
                  >
                    <stop offset="0.193699" stopColor="#074E9F" />
                    <stop offset="1" stopColor="#095FC3" />
                  </linearGradient>
                  <linearGradient
                    id="paint1_linear_2375_54956"
                    x1="20.64"
                    y1="43.5045"
                    x2="29.0814"
                    y2="-12.2876"
                    gradientUnits="userSpaceOnUse"
                  >
                    <stop stopColor="#074E9F" />
                    <stop offset="1" stopColor="#0A6EE1" />
                  </linearGradient>
                  <clipPath id="clip0_2375_54956">
                    <rect width="48" height="48" fill="white" />
                  </clipPath>
                </defs>
              </svg>
            }
            mobileLogo={
              <svg width="24" height="24" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clipPath="url(#clip0_2375_54956)">
                  <path
                    d="M34.2226 0H13.7857C6.18441 0 0 6.18418 0 13.781V34.2172C0 41.8182 6.18441 47.9982 13.7816 47.9982H34.2184C41.8198 47.9982 48 41.814 48 34.2172V13.781C48.0042 6.18418 41.8198 0 34.2226 0Z"
                    fill="url(#paint0_linear_2375_54956)"
                  />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M26.0769 48H34.2022C41.8035 48 47.9838 41.8158 47.9838 34.219V33.4037L33.5681 44.1662C31.242 45.9028 28.7072 47.1753 26.0769 48Z"
                    fill="#00964C"
                  />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M48 25.4457V34.2172C48 39.8185 44.6401 44.6519 39.828 46.8046C38.5506 46.126 37.4008 45.1639 36.4821 43.9335L23.9186 27.1062L11.355 43.9335C10.4543 45.1399 9.33127 46.0883 8.08372 46.7646C3.32027 44.5931 0 39.7866 0 34.2172V25.228L15.4365 4.55286C16.0654 3.59361 16.8682 2.7271 17.8374 2.00392C19.6491 0.65198 21.7756 1.80977e-06 23.8864 0H34.2226C41.8198 0 48.0042 6.18418 48 13.781V25.4457Z"
                    fill="url(#paint1_linear_2375_54956)"
                  />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M35.5509 42.6842L36.4848 43.935C37.4013 45.1627 38.5473 46.1226 39.8208 46.8014C44.6268 44.6459 47.9816 39.8161 47.9816 34.2189V33.4037L35.5509 42.6842Z"
                    fill="#22AB67"
                  />
                  <path d="M23.7784 25.4312H21.9896V27.22H23.7784V25.4312Z" fill="#F5FAFE" />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M13.7162 14.8354V14.1431H9.24417V18.7495C8.25291 20.3309 7.67981 22.201 7.67981 24.205C7.67981 29.8854 12.2847 34.4904 17.9652 34.4904C23.6457 34.4904 28.2505 29.8854 28.2505 24.205C28.2505 23.9379 28.2403 23.6733 28.2203 23.4114C29.2865 24.7147 30.9074 25.5465 32.7226 25.5465H34.9586C36.6875 25.5465 38.0891 26.948 38.0891 28.6769C38.0891 30.4057 36.6875 31.8073 34.9586 31.8073H26.9089V34.4904H34.9586C38.1694 34.4904 40.7723 31.8876 40.7723 28.6769C40.7723 25.4662 38.1694 22.8634 34.9586 22.8634H32.7226C30.9937 22.8634 29.5921 21.4619 29.5921 19.733C29.5921 18.0042 30.9937 16.6027 32.7226 16.6027H39.8779V13.9195H32.7226C29.7018 13.9195 27.2191 16.2233 26.9358 19.1697C25.1732 16.0362 21.8164 13.9195 17.9652 13.9195C16.45 13.9195 15.0114 14.2471 13.7162 14.8354ZM13.7162 17.9V21.7454H15.0579V18.1558L19.9772 20.839V18.1628L24.722 20.7176C23.458 18.2733 20.9066 16.6027 17.9652 16.6027C16.3914 16.6027 14.9293 17.0809 13.7162 17.9ZM25.3988 22.6057L21.3188 20.4089V23.099L16.3995 20.4158V23.087H12.3746V17.9442H10.5867V22.3673L10.5858 22.3708V26.0392C10.8976 27.298 11.5232 28.4331 12.3746 29.3566V25.3229H20.4244V31.4007C23.416 30.3785 25.5673 27.543 25.5673 24.205C25.5673 23.6564 25.5091 23.1213 25.3988 22.6057ZM15.9523 31.5379C15.1196 31.3098 14.3439 30.9437 13.6515 30.4657H13.7162V26.6645H15.9523V31.5379ZM17.0703 31.7551C17.3638 31.7896 17.6624 31.8073 17.9652 31.8073C18.3448 31.8073 18.718 31.7794 19.0827 31.7257V26.6645H17.0703V31.7551ZM12.3746 15.4847V16.6027H10.5858V15.4847H12.3746Z"
                    fill="#F5FAFE"
                  />
                </g>
                <defs>
                  <linearGradient
                    id="paint0_linear_2375_54956"
                    x1="46.752"
                    y1="41.375"
                    x2="2.72724"
                    y2="1.02179"
                    gradientUnits="userSpaceOnUse"
                  >
                    <stop offset="0.193699" stopColor="#074E9F" />
                    <stop offset="1" stopColor="#095FC3" />
                  </linearGradient>
                  <linearGradient
                    id="paint1_linear_2375_54956"
                    x1="20.64"
                    y1="43.5045"
                    x2="29.0814"
                    y2="-12.2876"
                    gradientUnits="userSpaceOnUse"
                  >
                    <stop stopColor="#074E9F" />
                    <stop offset="1" stopColor="#0A6EE1" />
                  </linearGradient>
                  <clipPath id="clip0_2375_54956">
                    <rect width="48" height="48" fill="white" />
                  </clipPath>
                </defs>
              </svg>
            }
            defaultLang={defaultLang}
            customLangChange={langChange}
            isPending={isPending}
          >
            {children}
          </Layout>
        </ProtectedLayout>
      </ThemeProvider>
    </Provider>
  );
};
