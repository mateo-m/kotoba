import type { SidebarsConfig } from "@docusaurus/plugin-content-docs";

const sidebars: SidebarsConfig = {
  docsSidebar: [
    {
      type: "category",
      label: "Getting started",
      collapsed: false,
      items: [
        "introduction",
        "essential/installation",
        "essential/quick-start",
        "essential/troubleshooting",
      ],
    },
    {
      type: "category",
      label: "Integration",
      collapsed: false,
      items: [
        "integration/index",
        "integration/bare-rgss",
        "integration/pokemon-essentials",
        "integration/pokemon-essentials-migration",
        "integration/third-party",
      ],
    },
    {
      type: "category",
      label: "Catalog & API",
      collapsed: true,
      items: [
        "essential/catalog-format",
        "essential/message-syntax",
        "essential/runtime-api",
      ],
    },
    {
      type: "category",
      label: "For translators",
      collapsed: false,
      items: [
        "translators/index",
        "translators/placeholders",
        "translators/handoff",
      ],
    },
    {
      type: "category",
      label: "Tooling",
      collapsed: true,
      items: [
        "tooling/index",
        "tooling/validation-cli",
        "tooling/tms",
        "tooling/crowdin",
        "tooling/simplelocalize",
        "tooling/tolgee",
        "tooling/xliff-po",
      ],
    },
    {
      type: "category",
      label: "Specs",
      collapsed: true,
      items: ["reference/map-event-codes", "reference/compatibility"],
    },
    {
      type: "category",
      label: "Contributors",
      collapsed: true,
      items: ["contributors/ci", "contributors/docker-images"],
    },
  ],
};

export default sidebars;
