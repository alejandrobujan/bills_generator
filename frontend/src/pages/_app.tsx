import "../styles/globals.scss";
import "../styles/builders.scss";
import Navbar from "../components/Navbar/Navbar";
import type { AppProps } from "next/app";

export default function App({ Component, pageProps }: AppProps) {
  return (
    <>
      <Navbar />
      <Component {...pageProps} />
    </>
  );
}
