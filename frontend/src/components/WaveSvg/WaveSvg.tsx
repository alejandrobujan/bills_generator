import styles from "./wave.module.scss";

export default function WaveSvg() {
  return (
    <>
      <svg
        viewBox="0 0 900 200"
        preserveAspectRatio="none"
        xmlns="http://www.w3.org/2000/svg"
        version="1.1"
        className={styles.Wave_svg}
      >
        <path
          d="M0 41L16.7 48.7C33.3 56.3 66.7 71.7 100 80.7C133.3 89.7 166.7 92.3 200 106.5C233.3 120.7 266.7 146.3 300 147.3C333.3 148.3 366.7 124.7 400 107.8C433.3 91 466.7 81 500 92.8C533.3 104.7 566.7 138.3 600 143.7C633.3 149 666.7 126 700 99.2C733.3 72.3 766.7 41.7 800 47.3C833.3 53 866.7 95 883.3 116L900 137"
          fill="none"
          stroke="#444444"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="miter"
        ></path>
      </svg>
    </>
  );
}
