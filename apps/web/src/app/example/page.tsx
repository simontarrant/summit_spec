import { AppShell } from "@/components/ui/app_shell";

const tabs = [
  { label: "Example", href: "/example" },
  { label: "Products", href: "/products" },
];

export default function Page() {
  return (
    <AppShell tabs={tabs}>
      <main className="ui-page">
      {/* Heading test */}
      <section className="ui-card">
        <p className="ui-label">System overview</p>
        <h1>Hiking Gear UI — Theme Test</h1>
        <p>
          This page demonstrates the visual system defined in <code>globals.css</code> and THEME.md.
          Everything below uses the theme tokens, colors, spacing, and shape language.
        </p>
      </section>

      {/* Typography test */}
      <section className="ui-card">
        <p className="ui-label">Type scale</p>
        <h2>Typography</h2>
        <h1>Heading 1 — Sora / Bold</h1>
        <h2>Heading 2 — Sora / Semi-bold</h2>
        <h3>Heading 3 — Sora / Medium</h3>
        <h4>Heading 4 — Sora / Medium</h4>
        <p className="mt-4">
          Body text uses <strong>Inter</strong>, with a relaxed line-height and charcoal/slate colors.
        </p>
        <p>
          Technical values: <span className="mono">R-Value 4.5</span>,{" "}
          <span className="mono">Weight: 395g</span>
        </p>
      </section>

      {/* Colors */}
      <section className="ui-card">
        <p className="ui-label">System palette</p>
        <h2>Color Palette</h2>
        <div className="grid grid-cols-3 gap-6 mt-4">
          <ColorSwatch name="Primary" className="bg-primary" />
          <ColorSwatch name="Accent" className="bg-accent" />
          <ColorSwatch name="Success" className="bg-success text-white" />
          <ColorSwatch name="Info" className="bg-info text-white" />
          <ColorSwatch name="Warning" className="bg-warning text-white" />
          <ColorSwatch name="Grey 200" className="bg-grey-200 text-charcoal" />
        </div>
      </section>

      {/* Buttons */}
      <section className="ui-card">
        <p className="ui-label">Controls</p>
        <h2>Buttons</h2>
        <div className="flex gap-4 mt-4">
          <button className="ui-button-primary">Primary Button</button>
          <button className="ui-button-accent">Accent Button</button>
        </div>
      </section>

      {/* Inputs */}
      <section className="ui-card">
        <p className="ui-label">Form fields</p>
        <h2>Input Fields</h2>
        <div className="space-y-3 mt-4">
          <div>
            <label className="block mb-1 text-charcoal">Name</label>
            <input className="ui-input w-full" placeholder="Enter your name" />
          </div>
          <div>
            <label className="block mb-1 text-charcoal">Weight (grams)</label>
            <input className="ui-input w-full mono" placeholder="300g" />
          </div>
        </div>
      </section>

      {/* Card / Shape language */}
      <section className="ui-card">
        <p className="ui-label">Shape language</p>
        <h2>Corners & Edges</h2>
        <div className="grid grid-cols-2 gap-6 mt-4">
          <div className="p-6 contour elevation corner-angle bg-white">
            <h3>Angled Corners</h3>
            <p>3–6px asymmetrical radii create a gear-inspired look.</p>
          </div>

          <div className="p-6 contour elevation chamfer bg-white">
            <h3>Chamfered Corner</h3>
            <p>The top-right corner has a 3px chamfer for visual character.</p>
          </div>
        </div>
      </section>
    </main>
    </AppShell>
  );
}

function ColorSwatch({
  name,
  className,
}: {
  name: string;
  className?: string;
}) {
  return (
    <div className="space-y-2">
      <div className={`ui-swatch ${className ?? ""}`} />
      <p className="text-center text-sm">{name}</p>
    </div>
  );
}
