import "../styles/globals.scss";
import "../styles/builders.scss";
import Navbar from "../components/LeftSection/LeftSection";
import type { AppProps } from "next/app";

export default function App({ Component, pageProps }: AppProps) {
  return (
    <>
      <Component {...pageProps} />
    </>
  );
}
