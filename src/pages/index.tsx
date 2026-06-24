import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import styles from "./index.module.css";

export default function Home(): JSX.Element {
  const { siteConfig } = useDocusaurusContext();

  return (
    <Layout title={siteConfig.title} description={siteConfig.tagline}>
      <div className={styles.page}>
        <header className={styles.hero}>
          <div className="container">
            <div className={styles.heroInner}>
              <div>
                <h1 className={styles.title}>{siteConfig.title}</h1>
                <p className={styles.lede}>{siteConfig.tagline}</p>
                <p className={styles.summary}>
                  Download a release ZIP, extract it beside Game.exe, paste one line in Script
                  Editor, and playtest.
                </p>
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
              <figure className={styles.bootLine}>
                <figcaption className={styles.bootCaption}>Script Editor</figcaption>
                <pre className={styles.bootCode}>
                  <code>load &quot;kotoba/boot.rb&quot;</code>
                </pre>
              </figure>
            </div>
          </div>
        </header>

        <section className={styles.paths}>
          <div className="container">
            <div className={styles.pathsGrid}>
              <article className={styles.pathCard}>
                <h2 className={styles.pathTitle}>Installing in a game</h2>
                <p className={styles.pathDesc}>
                  Pick a release ZIP for your kit, extract it next to Game.exe, add the boot line,
                  run the smoke test.
                </p>
                <Link className={styles.pathLink} to="/essential/installation">
                  Installation
                </Link>
              </article>
              <article className={styles.pathCard}>
                <h2 className={styles.pathTitle}>For translators</h2>
                <p className={styles.pathDesc}>
                  Edit JSON catalogs under Locales/, or export spreadsheets and import the finished
                  files back into the game folder.
                </p>
                <Link className={styles.pathLink} to="/translators/">
                  Translator docs
                </Link>
              </article>
            </div>
          </div>
        </section>
      </div>
    </Layout>
  );
}
