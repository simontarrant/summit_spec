## 1. Standard Page Layout

Used for any main page (Example, Gear Lists, Products, etc.):



```tsx

import { Page } from "@/components/ui/page";

import { Card, SectionLabel } from "@/components/ui/card";

  

export default function ExamplePage() {

return (

<Page>

<Card>

<SectionLabel>Section title</SectionLabel>

<h1>Heading</h1>

<p>Body content…</p>

</Card>

  

<Card>

<SectionLabel>Another section</SectionLabel>

<h2>Subheading</h2>

{/* more content */}

</Card>

</Page>

);

}

  

## Design inventory: patterns Claude should reuse

  

Stick this at the end of **THEME.md** or in a separate `PATTERNS.md`:

  

```markdown

# Design Inventory (Patterns)

  

## 1. Standard Page Layout

  

Used for any main page (Example, Gear Lists, Products, etc.):

  

```tsx

import { Page } from "@/components/ui/page";

import { Card, SectionLabel } from "@/components/ui/card";

  

export default function ExamplePage() {

return (

<Page>

<Card>

<SectionLabel>Section title</SectionLabel>

<h1>Heading</h1>

<p>Body content…</p>

</Card>

  

<Card>

<SectionLabel>Another section</SectionLabel>

<h2>Subheading</h2>

{/* more content */}

</Card>

</Page>

);

}

  

```

  

## 2. Form Card

  

```tsx

import { Card, SectionLabel } from "@/components/ui/card";

import { TextInput } from "@/components/ui/input";

import { PrimaryButton } from "@/components/ui/button";

  

<Card>

<SectionLabel>New gear list</SectionLabel>

<h2>Create list</h2>

  

<div className="mt-4 space-y-3">

<div>

<label className="block mb-1 text-charcoal">Name</label>

<TextInput placeholder="Summer Alps kit" />

</div>

  

<div>

<label className="block mb-1 text-charcoal">Base weight (g)</label>

<TextInput className="mono" placeholder="5200" />

</div>

</div>

  

<div className="mt-4 flex justify-end">

<PrimaryButton>Save list</PrimaryButton>

</div>

</Card>

  

```

  

## 3. Two-Column Data Layout

  

```tsx

<Card>

<SectionLabel>Summary</SectionLabel>

<h2>Gear list overview</h2>

  

<div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-6">

<div className="contour elevation corner-angle p-4 bg-white">

<h3>Sleep system</h3>

<p>Total R-value: <span className="mono">4.5</span></p>

<p>Weight: <span className="mono">1090 g</span></p>

</div>

  

<div className="contour elevation chamfer p-4 bg-white">

<h3>Packing</h3>

<p>Pack volume used: <span className="mono">38 L</span></p>

</div>

</div>

</Card>

  

```

  

## 4. Tab-aware Shell (optional)

  

When building a new view that needs the full shell manually:

import { AppShell } from "@/components/ui/app-shell";

import { Page } from "@/components/ui/page";

```tsx

export default function GearListsPage() {

return (

<AppShelltabs={[

{ label: "Example", href: "/", active: false },

{ label: "Gear Lists", href: "/gear-lists", active: true },

{ label: "Products", href: "/products", active: false },

]}

>

<Page>

{/* gear list content */}

</Page>

</AppShell>

);

}

```