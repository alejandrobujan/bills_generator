import Head from "next/head";
import NotificationManager from "../components/NotificationManager/NotificationManager";
import SlideSection from "../components/SlideSection/SlideSection";

export default function Home() {
  return (
    <>
      <Head>
        <title>Bill generator</title>
        <meta
          name="description"
          content="A site where you can generate high quality and customizable bills in a simple way"
        />
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>

      <NotificationManager>
        <SlideSection titles={["Generate bill", "Show bills"]}>
          <h1>Bill generator</h1>
          <h1>Bill list</h1>
        </SlideSection>
      </NotificationManager>
    </>
  );
}
