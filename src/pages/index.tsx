import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import styles from "./index.module.css";

const features = [
  {
    title: "Release ZIPs",
    description:
      "Bare RGSS and Essentials v16–v21, BES. Drop beside Game.exe and load kotoba/boot.rb.",
  },
  {
    title: "JSON catalogs",
    description:
      "Locales/en.json, fr.json, and more. Loaded at runtime — no compile step.",
  },
  {
    title: "Essentials bridge",
    description:
      "Adopt catalogs while existing _INTL scripts keep working.",
  },
  {
    title: "Translator handoff",
    description:
      "Export spreadsheets, import finished JSON back into the game folder.",
  },
];

export default function Home(): JSX.Element {
  const { siteConfig } = useDocusaurusContext();

  return (
    <Layout title={siteConfig.title} description={siteConfig.tagline}>
      <div className={styles.page}>
        <header className={styles.hero}>
          <div className="container">
            <div className={styles.heroInner}>
              <div>
                <p className={styles.eyebrow}>RPG Maker XP · Pokemon Essentials</p>
                <h1 className={styles.title}>{siteConfig.title}</h1>
                <p className={styles.lede}>{siteConfig.tagline}</p>
                <div className={styles.actions}>
                  <Link className={styles.primaryBtn} to="/essential/installation">
                    Install in a game
                  </Link>
                  <Link className={styles.secondaryBtn} to="/translators/">
                    For translators
                  </Link>
                  <Link className={styles.secondaryBtn} to="/essential/troubleshooting">
                    Troubleshooting
                  </Link>
                </div>
              </div>
              <aside className={styles.dialogue} aria-label="Script Editor entry point">
                <p className={styles.dialogueLabel}>Script Editor</p>
                <p className={styles.dialogueLine}>load &quot;kotoba/boot.rb&quot;</p>
                <p className={styles.dialogueHint}>
                  One line after extracting a release ZIP beside Game.exe.
                </p>
                <span className={styles.dialogueArrow} aria-hidden="true" />
              </aside>
            </div>
          </div>
        </header>

        <section className={styles.paths}>
          <div className="container">
            <div className={styles.pathsGrid}>
              <article className={styles.pathCard}>
                <p className={styles.pathRole}>Game folder</p>
                <h2 className={styles.pathTitle}>Installing in a game</h2>
                <p className={styles.pathDesc}>
                  Download a release ZIP, extract it next to Game.exe, paste the boot line, playtest.
                </p>
                <Link className={styles.pathLink} to="/essential/installation">
                  Installation guide →
                </Link>
              </article>
              <article className={styles.pathCard}>
                <p className={styles.pathRole}>Translation workflow</p>
                <h2 className={styles.pathTitle}>For translators</h2>
                <p className={styles.pathDesc}>
                  Placeholders, spreadsheet handoff, and how finished JSON goes back into Locales/.
                </p>
                <Link className={styles.pathLink} to="/translators/">
                  Translator docs →
                </Link>
              </article>
            </div>
          </div>
        </section>

        <section className={styles.features}>
          <div className="container">
            <div className={styles.featuresHeader}>
              <h2 className={styles.featuresTitle}>What you get</h2>
              <p className={styles.featuresIntro}>
                JSON catalogs beside the game, one Script Editor line to boot, adapters for Essentials kits.
              </p>
            </div>
            <div className={styles.featuresGrid}>
              {features.map(({ title, description }) => (
                <article key={title} className={styles.feature}>
                  <h3>{title}</h3>
                  <p>{description}</p>
                </article>
              ))}
            </div>
          </div>
        </section>
      </div>
    </Layout>
  );
}
