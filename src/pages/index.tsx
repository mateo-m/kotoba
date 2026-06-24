import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import Heading from "@theme/Heading";

const features = [
  {
    title: "Release ZIPs",
    description:
      "Bare RGSS and Essentials v16–v21, BES. Extract beside Game.exe, load kotoba/boot.rb.",
  },
  {
    title: "JSON catalogs",
    description:
      "Locales/en.json, fr.json, etc. Loaded at runtime. No compile step.",
  },
  {
    title: "Essentials bridge",
    description:
      "Adopt catalogs while existing _INTL scripts keep working.",
  },
  {
    title: "Translator handoff",
    description:
      "Export spreadsheets, import finished JSON back into the game.",
  },
];

export default function Home(): JSX.Element {
  const { siteConfig } = useDocusaurusContext();

  return (
    <Layout title={siteConfig.title} description={siteConfig.tagline}>
      <header className="hero hero--kotoba">
        <div className="container">
          <Heading as="h1" className="hero__title">
            {siteConfig.title}
          </Heading>
          <p className="hero__subtitle">{siteConfig.tagline}</p>
          <p className="hero__tagline">
            JSON catalogs beside Game.exe. One Script Editor line to boot.
          </p>
          <div className="heroButtons">
            <Link className="button button--primary button--lg" to="/essential/installation">
              Install in a game
            </Link>
            <Link className="button button--outline button--lg" to="/translators/">
              For translators
            </Link>
            <Link className="button button--outline button--lg" to="/essential/troubleshooting">
              Troubleshooting
            </Link>
          </div>
        </div>
      </header>
      <main>
        <section className="features">
          <div className="container">
            <div className="features__grid">
              {features.map(({ title, description }) => (
                <article key={title} className="feature-card">
                  <Heading as="h3">{title}</Heading>
                  <p>{description}</p>
                </article>
              ))}
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}
