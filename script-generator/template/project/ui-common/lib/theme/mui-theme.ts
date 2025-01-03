import {
  Breakpoint,
  createTheme,
  responsiveFontSizes,
} from "@mui/material/styles";

export const breakpoints: { [key in Breakpoint]: number } = {
  mobile: 0,
  tablet: 744,
  desktop: 1024,
};

const createdTheme = createTheme({
  // font
  typography: {
    fontFamily: "IBMPlexSansThai",
    D3_SemiBold: {
      fontSize: "40px",
      lineHeight: "52px",
      fontWeight: 600,
    },
    D4_SemiBold: {
      fontSize: "32px",
      lineHeight: "40px",
      fontWeight: 600,
    },
    D5_SemiBold: {
      fontSize: "24px",
      lineHeight: "32px",
      fontWeight: 600,
    },
    D6_SemiBold: {
      fontSize: "18px",
      lineHeight: "26px",
      fontWeight: 600,
    },
    D7_Regular: {
      fontSize: "14px",
      lineHeight: "20px",
      fontWeight: 400,
    },
    D7_SemiBold: {
      fontSize: "14px",
      lineHeight: "20px",
      fontWeight: 600,
    },
    H2_Bold: {
      fontSize: "32px",
      lineHeight: "48px",
      fontWeight: 700,
      [`@media (max-width:${breakpoints.tablet}px)`]: {
        fontSize: "24px",
        lineHeight: "36px",
      },
    },
    H4_Bold: {
      fontSize: "24px",
      lineHeight: "36px",
      fontWeight: 700,
      [`@media (max-width:${breakpoints.tablet}px)`]: {
        fontSize: "18px",
        lineHeight: "26px",
      },
    },
    H6_SemiBold: {
      fontSize: "18px",
      lineHeight: "26px",
      fontWeight: 600,
      [`@media (max-width:${breakpoints.tablet}px)`]: {
        fontSize: "16px",
        lineHeight: "24px",
      },
    },
    S4_Regular: {
      fontSize: "16px",
      lineHeight: "24px",
      fontWeight: 400,
      color: "#344054",
    },
    T2_SemiBold: {
      fontSize: "22px",
      lineHeight: "32px",
      fontWeight: 600,
    },
    T3_SemiBold: {
      fontSize: "20px",
      lineHeight: "30px",
      fontWeight: 600,
    },
    T4_SemiBold: {
      fontSize: "18px",
      lineHeight: "28px",
      fontWeight: 600,
    },
    T5_SemiBold: {
      fontSize: "16px",
      lineHeight: "24px",
      fontWeight: 600,
    },
    B3_Regular: {
      fontSize: "18px",
      lineHeight: "28px",
      fontWeight: 400,
    },
    BH3_SemiBold: {
      fontSize: "18px",
      lineHeight: "28px",
      fontWeight: 600,
    },
    B4_Regular: {
      fontSize: "16px",
      lineHeight: "24px",
      fontWeight: 400,
    },
    BH4_SemiBold: {
      fontSize: "16px",
      lineHeight: "24px",
      fontWeight: 600,
    },
    B5_Regular: {
      fontSize: "14px",
      lineHeight: "22px",
      fontWeight: 400,
    },
    BH5_SemiBold: {
      fontSize: "14px",
      lineHeight: "22px",
      fontWeight: 600,
    },
    B6_Regular: {
      fontSize: "12px",
      lineHeight: "18px",
      fontWeight: 400,
    },
    BH6_SemiBold: {
      fontSize: "12px",
      lineHeight: "18px",
      fontWeight: 600,
    },
    LB4_Regular: {
      fontWeight: 400,
      fontSize: "16px",
      lineHeight: "24px",
      color: "#344054",
    },
    LU3_Regular: {
      fontSize: "18px",
      lineHeight: "28px",
      fontWeight: 400,
      textDecoration: "underline",
    },
    L3_Regular: {
      fontSize: "18px",
      lineHeight: "28px",
      fontWeight: 400,
    },
    LU4_Regular: {
      fontSize: "16px",
      lineHeight: "24px",
      fontWeight: 400,
      textDecoration: "underline",
    },
    L4_Regular: {
      fontSize: "16px",
      lineHeight: "24px",
      fontWeight: 400,
    },
    LU5_Regular: {
      fontSize: "14px",
      lineHeight: "22px",
      fontWeight: 400,
      textDecoration: "underline",
    },
    L5_Regular: {
      fontSize: "14px",
      lineHeight: "22px",
      fontWeight: 400,
    },
    P4_Regular: {
      fontSize: "16px",
      lineHeight: "28px",
      fontWeight: 400,
    },
    PH4_SemiBold: {
      fontSize: "16px",
      lineHeight: "28px",
      fontWeight: 600,
    },
    P5_Regular: {
      fontSize: "14px",
      lineHeight: "26px",
      fontWeight: 400,
    },
    PH5_SemiBold: {
      fontSize: "14px",
      lineHeight: "26px",
      fontWeight: 600,
    },
    P_Regular: {
      fontSize: "18px",
      lineHeight: "32px",
      fontWeight: 400,
    },
    PH_SemiBold: {
      fontSize: "18px",
      lineHeight: "32px",
      fontWeight: 600,
    },
    BT5_SemiBold: {
      fontSize: "14px",
      lineHeight: "20px",
      fontWeight: 600,
    },
    BT4_SemiBold: {
      fontSize: "16px",
      lineHeight: "24px",
      fontWeight: 600,
    },
    BT3_SemiBold: {
      fontSize: "18px",
      lineHeight: "28px",
      fontWeight: 600,
    },
  },
  // spacing: 8,
  // // สีตรีม
  palette: {
    primary: {
      main: "#074E9F",
      contrastText: "#fff",
      light: "#0A6EE1",
      dark: "#042F5F",
    },
    secondary: {
      main: "#22AB67",
      contrastText: "#fff",
      light: "#6ACD9C",
      dark: "#35674E",
    },
    success: {
      main: "#07A721",
      contrastText: "#fff",
      light: "#72BC76",
      dark: "#05811A",
    },
    error: {
      main: "#D92D20",
      contrastText: "#fff",
      light: "#E17976",
      dark: "#A82319",
    },
    //   background: {
    //     default: "#CFD2D6",
    //   },
  },
  breakpoints: {
    values: {
      mobile: breakpoints.mobile,
      tablet: breakpoints.tablet,
      desktop: breakpoints.desktop,
    },
  },
});

export const theme = responsiveFontSizes(createdTheme);
