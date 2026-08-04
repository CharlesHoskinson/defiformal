/* TypeScript 7 requires declarations for side-effect imports of non-code
   assets. Vite resolves these at build time; this only tells tsc they exist. */
declare module "*.css";
declare module "*.svg";
declare module "*.png";
