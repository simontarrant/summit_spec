import { AppShell } from "@/components/ui/app_shell";

export const preferredRegion = "syd1";

const tabs = [
  { label: "Example", href: "/example" },
  { label: "Products", href: "/products" },
  { label: "About", href: "/about" },
];

export default function AboutPage() {
  return (
    <AppShell tabs={tabs} pageTitle="About">
      <main className="ui-page" style={{ maxWidth: "640px" }}>
        <section className="ui-card">
          <p className="ui-label">The origin story</p>
          <h2 className="text-primary">Down Booties &amp; Spreadsheets</h2>
          <p>
            Summit Spec started with a problem that wouldn&apos;t leave me alone. The problem recurred any time I needed to buy a new piece of hiking gear. The tipping point, however, was when I was shopping for a Christmas present for a friend: a pair of humble down booties. Sounds straightfoward.
          </p>
          <p>
            Alas, not quite. I sunk hours into hunting down fill-power ratings, weights, packed sizes, and building excel formulas to calculate warmth-to-weight ratios across brands and retailers.There had to be a better way to compare gear.
          </p>
          <p>
            So I decided to build the tool I wished existed: a comprehensive hiking gear comparison engine that makes it easy to filter, sort, and compare the specs that actually matter.Additionally, as the site grows, we will be able to provide each other even more accurate community ratings/opinions on brands&apos; stated specs
          </p>
        </section>

        <section className="ui-card">
          <p className="ui-label">What this is</p>
          <h2 className="text-primary">A Gear Comparison Engine</h2>
          <p>
            Summit Spec is built for hikers, thru-hikers, and outdoor enthusiasts who care about the numbers. Whether you&apos;re optimising your pack weight for a weekend mish or researching sleep systems for months long trail expeditions, this tool lets you compare products side by side on any spec that matters.
          </p>
          <p>
            No sponsored rankings. No affiliate-driven &ldquo;best of&rdquo; lists. Just the data, presented clearly so we can all make our own informed decisions.
          </p>
        </section>

        <section className="ui-card">
          <p className="ui-label">Support the outdoors</p>
          <h2 className="text-primary">Trail Conservation</h2>
          <p>
            The trails we love need looking after. That&apos;s why you&apos;ll find a link to{" "}
            <a
              href="https://www.wildernessaustralia.org.au/"
              className="text-accent underline"
              target="_blank"
              rel="noopener noreferrer"
            >
              Wilderness Australia
            </a>{" "}
            in the top bar. If Summit Spec helps you find the right gear, consider giving back to the places where you&apos;ll use it, wherever they may be.
          </p>
        </section>
      </main>
    </AppShell>
  );
}
