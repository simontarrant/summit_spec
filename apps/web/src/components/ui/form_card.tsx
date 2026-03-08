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
