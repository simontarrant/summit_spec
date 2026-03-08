"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import {
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
} from "@/components/ui/modal";
import { LinearInput } from "@/components/ui/linear-input";
import { PrimaryButton, AccentButton } from "@/components/ui/button";
import { SectionLabel } from "@/components/ui/card";
import { FieldGroup, FieldRow } from "@/components/ui/field-group";
import { LinearSelect } from "@/components/ui/linear-select";
import { LinearNumberInput } from "./linear-number-input";

interface Brand {
  id: number;
  name: string;
}

interface CreateProductModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export function CreateProductModal({
  isOpen,
  onClose,
  onSuccess,
}: CreateProductModalProps) {
  const router = useRouter();
  const [brands, setBrands] = useState<Brand[]>([]);
  const [isLoadingBrands, setIsLoadingBrands] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Product form state
  const [productName, setProductName] = useState("");
  const [category, setCategory] = useState<"SLEEPING_PAD">("SLEEPING_PAD");
  const [visibility, setVisibility] = useState<
    "PRIVATE"
  >("PRIVATE");
  const [selectedBrandId, setSelectedBrandId] = useState<string>("");

  // Product specs (will become the default variant)
  const [weightG, setWeightG] = useState("");
  const [packedVolumeL, setPackedVolumeL] = useState("");
  const [sleepingPadRValue, setSleepingPadRValue] = useState("");

  // Fetch brands when modal opens
  useEffect(() => {
    if (isOpen) {
      fetchBrands();
    }
  }, [isOpen]);

  const fetchBrands = async () => {
    try {
      setIsLoadingBrands(true);
      const response = await fetch("/api/brands");
      if (!response.ok) throw new Error("Failed to fetch brands");
      const data = await response.json();
      setBrands(data.brands);
    } catch (error) {
      console.error("Error fetching brands:", error);
    } finally {
      setIsLoadingBrands(false);
    }
  };

  const resetForm = () => {
    setProductName("");
    setCategory("SLEEPING_PAD");
    setVisibility("PRIVATE");
    setSelectedBrandId("");
    setWeightG("");
    setPackedVolumeL("");
    setSleepingPadRValue("");
    setError(null);
  };

  const handleClose = () => {
    resetForm();
    onClose();
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    // Validation
    if (!productName.trim()) {
      setError("Product name is required");
      return;
    }

    if (!weightG || isNaN(Number(weightG))) {
      setError("Weight is required and must be a valid number");
      return;
    }

    try {
      setIsSubmitting(true);

      const payload = {
        name: productName.trim(),
        category,
        visibility,
        brandId: selectedBrandId ? parseInt(selectedBrandId) : undefined,
        variants: [
          {
            variantName: undefined,
            isDefault: true,
            weightG: parseInt(weightG),
            packedVolumeL: packedVolumeL ? parseFloat(packedVolumeL) : undefined,
            sleepingPadRValue: sleepingPadRValue
              ? parseFloat(sleepingPadRValue)
              : undefined,
          },
        ],
      };

      const response = await fetch("/api/products", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.error || "Failed to create product");
      }

      const data = await response.json();
      onSuccess();
      handleClose();

      // Redirect to the new product page
      router.push(`/products/${data.product.id}`);
    } catch (error) {
      console.error("Error creating product:", error);
      setError(
        error instanceof Error ? error.message : "Failed to create product"
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={handleClose} className="max-w-3xl">
      <form onSubmit={handleSubmit}>
        <ModalHeader onClose={handleClose}>
          <div>
            <SectionLabel>New Product</SectionLabel>
            <h2>Create Custom Product</h2>
          </div>
        </ModalHeader>

        <ModalBody className="space-y-6 max-h-[70vh] overflow-y-auto">
          {error && (
            <div className="p-3 bg-red-50 border border-red-200 rounded text-red-700 text-sm">
              {error}
            </div>
          )}

          {/* Product Details */}
          <div className="space-y-4">
            <SectionLabel>Product Details</SectionLabel>

                <FieldGroup>
                <FieldRow label="Product Name *">
                    <LinearInput
                    placeholder="e.g., Custom UL Sleeping Pad"
                    value={productName}
                    onChange={(e) => setProductName(e.target.value)}
                    required
                    />
                </FieldRow>

                <FieldRow label="Category">
                    <LinearSelect
                    value={category}
                    onChange={(e) =>
                        setCategory(e.target.value as "SLEEPING_PAD")
                    }
                    >
                    <option value="SLEEPING_PAD">Sleeping Pad</option>
                    </LinearSelect>
                </FieldRow>

                <FieldRow label="Visibility">
                    <LinearSelect
                    value={visibility}
                    onChange={(e) =>
                        setVisibility(
                        e.target.value as  "PRIVATE"
                        )
                    }
                    >
                    <option value="PRIVATE">Private (only you)</option>
                    {/* <option value="PUBLIC">Public (everyone)</option>
                    <option value="UNLISTED">Unlisted (via link)</option> */}
                    </LinearSelect>
                </FieldRow>

                <FieldRow label="Brand">
                    <LinearSelect
                    value={selectedBrandId}
                    onChange={(e) => setSelectedBrandId(e.target.value)}
                    disabled={isLoadingBrands}
                    >
                    <option value="">
                        {isLoadingBrands ? "Loading..." : "No brand"}
                    </option>
                    {brands.map((brand) => (
                        <option key={brand.id} value={brand.id}>
                        {brand.name}
                        </option>
                    ))}
                    </LinearSelect>
                </FieldRow>
                </FieldGroup>

          </div>

          {/* Product Specifications */}
          <div className="space-y-4">
            <SectionLabel>Specifications</SectionLabel>

                <FieldGroup>
                <FieldRow label="Weight (g) *">
                    <LinearNumberInput
                    value={weightG}
                    onChange={(e) => setWeightG(e.target.value)}
                    placeholder="450"
                    />
                </FieldRow>

                <FieldRow label="Packed Volume (L)">
                    <LinearNumberInput
                    value={packedVolumeL}
                    onChange={(e) => setPackedVolumeL(e.target.value)}
                    placeholder="1.5"
                    />
                </FieldRow>

                <FieldRow label="R-Value">
                    <LinearNumberInput
                    value={sleepingPadRValue}
                    onChange={(e) => setSleepingPadRValue(e.target.value)}
                    placeholder="4.2"
                    />
                </FieldRow>
                </FieldGroup>

          </div>
        </ModalBody>

        <ModalFooter>
          <button
            type="button"
            onClick={handleClose}
            className="px-4 py-2 text-slate hover:text-charcoal transition-colors cursor-pointer"
            disabled={isSubmitting}
          >
            Cancel
          </button>
          <PrimaryButton type="submit" disabled={isSubmitting}>
            {isSubmitting ? "Creating..." : "Create Product"}
          </PrimaryButton>
        </ModalFooter>
      </form>
    </Modal>
  );
}
