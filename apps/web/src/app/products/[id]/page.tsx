"use client";

import { useEffect, useState, useCallback } from "react";
import { useRouter, useParams } from "next/navigation";
import { Page } from "@/components/ui/page";
import { Card, SectionLabel } from "@/components/ui/card";
import { PrimaryButton } from "@/components/ui/button";

export const preferredRegion = "syd1";

interface SleepingPadDetail {
  sleeping_pad_r_value: number | null;
}

interface ProductVariant {
  id: number;
  variant_name: string | null;
  is_default: boolean;
  weight_g: number;
  packed_volume_l: number | null;
  sleeping_pad_detail: SleepingPadDetail | null;
  created_at: string;
  updated_at: string;
}

interface Product {
  id: number;
  name: string;
  category: string;
  visibility: string;
  owner_user_id: number | null;
  brand: {
    id: number;
    name: string;
  } | null;
  owner: {
    id: number;
    username: string;
    name: string | null;
  } | null;
  variants: ProductVariant[];
  created_at: string;
  updated_at: string;
}

export default function ProductDetailPage() {
  const [product, setProduct] = useState<Product | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();
  const params = useParams();

  const fetchProduct = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);
      const response = await fetch(`/api/products/${params.id}`);

      if (!response.ok) {
        if (response.status === 404) {
          setError("Product not found");
        } else {
          throw new Error("Failed to fetch product");
        }
        return;
      }

      const data = await response.json();
      setProduct(data.product);
    } catch (error) {
      console.error("Error fetching product:", error);
      setError("Failed to load product");
    } finally {
      setIsLoading(false);
    }
  }, [params.id]);

  useEffect(() => {
    fetchProduct();
  }, [fetchProduct]);

  const formatCategory = (category: string) => {
    return category
      .split("_")
      .map((word) => word.charAt(0) + word.slice(1).toLowerCase())
      .join(" ");
  };

  if (isLoading) {
    return (
      <Page>
        <Card>
          <p className="text-center text-slate">Loading product...</p>
        </Card>
      </Page>
    );
  }

  if (error || !product) {
    return (
      <Page>
        <Card>
          <div className="text-center py-8">
            <h2 className="mb-2">{error || "Product not found"}</h2>
            <p className="mb-4">
              The product you&apos;re looking for doesn&apos;t exist or couldn&apos;t be
              loaded.
            </p>
            <PrimaryButton onClick={() => router.push("/products")}>
              Back to Products
            </PrimaryButton>
          </div>
        </Card>
      </Page>
    );
  }

  return (
    <Page>
      {/* Product Header */}
      <Card>
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              <SectionLabel>Product</SectionLabel>
              {product.owner_user_id && (
                <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-info text-white">
                  My Product
                </span>
              )}
            </div>

            <h1 className="mb-4">{product.name}</h1>

            <div className="grid grid-cols-2 gap-x-8 gap-y-3">
              <div>
                <SectionLabel>Brand</SectionLabel>
                <p className="text-charcoal">{product.brand?.name || "No brand"}</p>
              </div>

              <div>
                <SectionLabel>Category</SectionLabel>
                <p className="mono text-sm">{formatCategory(product.category)}</p>
              </div>

              {product.owner && (
                <div>
                  <SectionLabel>Owner</SectionLabel>
                  <p className="text-charcoal">
                    {product.owner.name || product.owner.username}
                  </p>
                </div>
              )}
            </div>
          </div>

          <PrimaryButton onClick={() => router.push("/products")}>
            Back
          </PrimaryButton>
        </div>
      </Card>

      {/* Variants Section */}
      <Card>
        <div className="mb-3">
          <SectionLabel>Variants</SectionLabel>
          <h2>Product Variants</h2>
          <p className="text-sm mt-1 text-slate">
            {product.variants.length}{" "}
            {product.variants.length === 1 ? "variant" : "variants"} available
          </p>
        </div>

        {product.variants.length === 0 ? (
          <div className="text-center py-8 border-t border-slate-100">
            <p className="text-slate">No variants available for this product</p>
          </div>
        ) : (
          <div className="text-sm">
            {/* Header row */}
            <div className="grid grid-cols-12 gap-0 border-b border-slate-100 pb-2">
              <div className="col-span-4 px-2">
                <SectionLabel>Variant</SectionLabel>
              </div>
              <div className="col-span-2 px-2">
                <SectionLabel>Weight</SectionLabel>
              </div>
              <div className="col-span-3 px-2">
                <SectionLabel>Volume</SectionLabel>
              </div>
              {product.category === "SLEEPING_PAD" && (
                <div className="col-span-3 px-2">
                  <SectionLabel>R-Value</SectionLabel>
                </div>
              )}
            </div>

            {/* Variant rows */}
            {product.variants.map((variant) => (
              <div
                key={variant.id}
                className="grid grid-cols-12 gap-0 border-b border-slate-100"
              >
                <div className="col-span-4 px-2 py-2 border-r border-slate-100 flex items-center">
                  <span className="text-charcoal font-medium">
                    {variant.variant_name || "Standard"}
                  </span>
                  {variant.is_default && (
                    <span className="ml-2 text-xs text-slate">(default)</span>
                  )}
                </div>

                <div className="col-span-2 px-2 py-2 border-r border-slate-100 flex items-center">
                  <span className="font-mono text-sm text-slate">
                    {variant.weight_g}g
                  </span>
                </div>

                <div className="col-span-3 px-2 py-2 border-r border-slate-100 flex items-center">
                  <span className="font-mono text-sm text-slate">
                    {variant.packed_volume_l ? `${variant.packed_volume_l}L` : "—"}
                  </span>
                </div>

                {product.category === "SLEEPING_PAD" && (
                  <div className="col-span-3 px-2 py-2 flex items-center">
                    <span className="font-mono text-sm text-slate">
                      {variant.sleeping_pad_detail?.sleeping_pad_r_value ?? "—"}
                    </span>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </Card>
    </Page>
  );
}
