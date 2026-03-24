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
      <main className="ui-page">
        <section className="ui-card">
          <p className="ui-label">The origin story</p>
          <h2>Down Booties & Spreadsheets</h2>
          <p>
            Summit Spec started the way many side-projects do — with a problem
            that wouldn&apos;t leave me alone. I&apos;m a 23-year-old from
            Australia and I was shopping for a Christmas present for a friend:
            a pair of down booties. Simple enough, right?
          </p>
          <p>
            Not quite. I spent hours building Excel comparison sheets, hunting
            down fill-power ratings, weights, packed sizes, and warmth-to-weight
            ratios across dozens of brands and retailers. By the time I finally
            picked a pair, I was equal parts satisfied and frustrated — there had
            to be a better way to compare hiking gear.
          </p>
          <p>
            That frustration was the tipping point. I decided to build the tool I
            wished existed: a comprehensive hiking gear comparison engine that
            makes it easy to filter, sort, and compare the specs that actually
            matter.
          </p>
        </section>

        <section className="ui-card">
          <p className="ui-label">What this is</p>
          <h2>A Gear Comparison Engine</h2>
          <p>
            Summit Spec is built for hikers, thru-hikers, and outdoor
            enthusiasts who care about the numbers. Whether you&apos;re
            optimising your pack weight for a weekend trip or researching sleep
            systems for a months-long trail, this tool lets you compare products
            side by side on the specs that matter — weight, warmth ratings,
            R-values, packed dimensions, and more.
          </p>
          <p>
            No sponsored rankings. No affiliate-driven &ldquo;best of&rdquo;
            lists. Just data, presented clearly so you can make your own
            informed decisions.
          </p>
        </section>

        <section className="ui-card">
          <p className="ui-label">Support the outdoors</p>
          <h2>Trail Conservation</h2>
          <p>
            The trails we love need looking after. That&apos;s why you&apos;ll
            find a link to{" "}
            <a
              href="https://www.wildernessaustralia.org.au/"
              className="text-accent underline"
              target="_blank"
              rel="noopener noreferrer"
            >
              Wilderness Australia
            </a>{" "}
            in the top bar. If Summit Spec helps you find the right gear,
            consider giving back to the places where you&apos;ll use it.
          </p>
        </section>
      </main>
    </AppShell>
  );
}
