import { Suspense } from "react";
import { ProductSearch } from "./product-search";

export default function ProductsPage() {
  return (
    <Suspense>
      <ProductSearch />
    </Suspense>
  );
}
