import { Suspense } from "react";
import { ProductSearch } from "./product-search";

export const preferredRegion = "syd1";

export default function ProductsPage() {
  return (
    <Suspense>
      <ProductSearch />
    </Suspense>
  );
}
