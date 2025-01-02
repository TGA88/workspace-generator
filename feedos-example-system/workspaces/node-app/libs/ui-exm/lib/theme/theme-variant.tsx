import React from "react";

// You do not have to import this file in anywhere. It's automatically imported byself.
declare module "@mui/material/styles" {
  // You can change "subtitle3" name with that you defined in your "theme.js" named of variant's name.
  interface TypographyVariants {
    B3_Regular: React.CSSProperties;
    B4_Regular: React.CSSProperties;
    B5_Regular: React.CSSProperties;
    B6_Regular: React.CSSProperties;
    BH3_SemiBold: React.CSSProperties;
    BH4_SemiBold: React.CSSProperties;
    BH5_SemiBold: React.CSSProperties;
    BH6_SemiBold: React.CSSProperties;
    BT3_SemiBold: React.CSSProperties;
    BT4_SemiBold: React.CSSProperties;
    BT5_SemiBold: React.CSSProperties;
    D3_SemiBold: React.CSSProperties;
    D4_SemiBold: React.CSSProperties;
    D5_SemiBold: React.CSSProperties;
    D6_SemiBold: React.CSSProperties;
    D7_Regular: React.CSSProperties;
    D7_SemiBold: React.CSSProperties;
    H2_Bold: React.CSSProperties;
    H4_Bold: React.CSSProperties;
    H6_SemiBold: React.CSSProperties;
    L3_Regular: React.CSSProperties;
    L4_Regular: React.CSSProperties;
    L5_Regular: React.CSSProperties;
    LB4_Regular: React.CSSProperties;
    LU3_Regular: React.CSSProperties;
    LU4_Regular: React.CSSProperties;
    LU5_Regular: React.CSSProperties;
    P4_Regular: React.CSSProperties;
    P5_Regular: React.CSSProperties;
    P_Regular: React.CSSProperties;
    PH4_SemiBold: React.CSSProperties;
    PH5_SemiBold: React.CSSProperties;
    PH_SemiBold: React.CSSProperties;
    S4_Regular: React.CSSProperties;
    T2_SemiBold: React.CSSProperties;
    T3_SemiBold: React.CSSProperties;
    T4_SemiBold: React.CSSProperties;
    T5_SemiBold: React.CSSProperties;
  }

  // Allow configuration using `createTheme`
  interface TypographyVariantsOptions {
    B3_Regular?: React.CSSProperties;
    B4_Regular?: React.CSSProperties;
    B5_Regular?: React.CSSProperties;
    B6_Regular?: React.CSSProperties;
    BH3_SemiBold?: React.CSSProperties;
    BH4_SemiBold?: React.CSSProperties;
    BH5_SemiBold?: React.CSSProperties;
    BH6_SemiBold?: React.CSSProperties;
    BT3_SemiBold?: React.CSSProperties;
    BT4_SemiBold?: React.CSSProperties;
    BT5_SemiBold?: React.CSSProperties;
    D3_SemiBold?: React.CSSProperties;
    D4_SemiBold?: React.CSSProperties;
    D5_SemiBold?: React.CSSProperties;
    D6_SemiBold?: React.CSSProperties;
    D7_Regular?: React.CSSProperties;
    D7_SemiBold?: React.CSSProperties;
    H2_Bold?: React.CSSProperties;
    H4_Bold?: React.CSSProperties;
    H6_SemiBold?: React.CSSProperties;
    L3_Regular?: React.CSSProperties;
    L4_Regular?: React.CSSProperties;
    L5_Regular?: React.CSSProperties;
    LB4_Regular?: React.CSSProperties;
    LU3_Regular?: React.CSSProperties;
    LU4_Regular?: React.CSSProperties;
    LU5_Regular?: React.CSSProperties;
    P4_Regular?: React.CSSProperties;
    P5_Regular?: React.CSSProperties;
    P_Regular?: React.CSSProperties;
    PH4_SemiBold?: React.CSSProperties;
    PH5_SemiBold?: React.CSSProperties;
    PH_SemiBold?: React.CSSProperties;
    S4_Regular?: React.CSSProperties;
    T2_SemiBold?: React.CSSProperties;
    T3_SemiBold?: React.CSSProperties;
    T4_SemiBold?: React.CSSProperties;
    T5_SemiBold?: React.CSSProperties;
  }

  interface BreakpointOverrides {
    xs: false; // removes the `xs` breakpoint
    sm: false;
    md: false;
    lg: false;
    xl: false;
    mobile: true; // adds the `mobile` breakpoint
    tablet: true;
    desktop: true;
  }
}

// Update the Typography's variant prop options
declare module "@mui/material/Typography" {
  interface TypographyPropsVariantOverrides {
    B3_Regular: true;
    B4_Regular: true;
    B5_Regular: true;
    B6_Regular: true;
    BH3_SemiBold: true;
    BH4_SemiBold: true;
    BH5_SemiBold: true;
    BH6_SemiBold: true;
    BT3_SemiBold: true;
    BT4_SemiBold: true;
    BT5_SemiBold: true;
    D3_SemiBold: true;
    D4_SemiBold: true;
    D5_SemiBold: true;
    D6_SemiBold: true;
    D7_Regular: true;
    D7_SemiBold: true;
    H2_Bold: true;
    H4_Bold: true;
    H6_SemiBold: true;
    L3_Regular: true;
    L4_Regular: true;
    L5_Regular: true;
    LB4_Regular: true;
    LU3_Regular: true;
    LU4_Regular: true;
    LU5_Regular: true;
    P4_Regular: true;
    P5_Regular: true;
    P_Regular: true;
    PH4_SemiBold: true;
    PH5_SemiBold: true;
    PH_SemiBold: true;
    S4_Regular: true;
    T2_SemiBold: true;
    T3_SemiBold: true;
    T4_SemiBold: true;
    T5_SemiBold: true;
  }
}
