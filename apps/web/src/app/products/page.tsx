"use client";

import { useState } from "react";
import Link from "next/link";
import { AppShell } from "@/components/ui/app_shell";
import { LinearSelect } from "@/components/ui/linear-select";

const tabs = [
  { label: "Example", href: "/example" },
  { label: "Products", href: "/products" },
];

interface Product {
  id: number;
  name: string;
  brand: string;
  category: string;
  weight: string;
  price: string;
  rating: number;
}

const FAKE_PRODUCTS: Product[] = [
  {
    id: 1,
    name: "NeoAir XLite NXT",
    brand: "Therm-a-Rest",
    category: "Sleeping Pad",
    weight: "350g",
    price: "$229.95",
    rating: 4.8,
  },
  {
    id: 2,
    name: "Tensor Insulated",
    brand: "Nemo",
    category: "Sleeping Pad",
    weight: "425g",
    price: "$199.95",
    rating: 4.6,
  },
  {
    id: 3,
    name: "Flash Insulated",
    brand: "Sea to Summit",
    category: "Sleeping Pad",
    weight: "465g",
    price: "$189.95",
    rating: 4.5,
  },
  {
    id: 4,
    name: "Circuit UL 68",
    brand: "Osprey",
    category: "Backpack",
    weight: "1250g",
    price: "$349.95",
    rating: 4.7,
  },
  {
    id: 5,
    name: "Arc Blast 55",
    brand: "Zpacks",
    category: "Backpack",
    weight: "590g",
    price: "$325.00",
    rating: 4.9,
  },
  {
    id: 6,
    name: "Spark 15°F",
    brand: "Enlightened Equipment",
    category: "Quilt",
    weight: "625g",
    price: "$365.00",
    rating: 4.8,
  },
  {
    id: 7,
    name: "Revelation 20°F",
    brand: "Enlightened Equipment",
    category: "Quilt",
    weight: "510g",
    price: "$315.00",
    rating: 4.9,
  },
  {
    id: 8,
    name: "Vesper 20°F",
    brand: "Katabatic Gear",
    category: "Quilt",
    weight: "545g",
    price: "$385.00",
    rating: 4.9,
  },
];

type SortColumn = "name" | "brand" | "category" | "weight" | "price" | "rating";
type SortDirection = "asc" | "desc";

export default function ProductsPage() {
  const [categoryFilter, setCategoryFilter] = useState<string>("All");
  const [sortColumn, setSortColumn] = useState<SortColumn>("name");
  const [sortDirection, setSortDirection] = useState<SortDirection>("asc");

  const categories = ["All", ...Array.from(new Set(FAKE_PRODUCTS.map(p => p.category)))];

  const handleSort = (column: SortColumn) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortColumn(column);
      setSortDirection("asc");
    }
  };

  const filteredProducts = FAKE_PRODUCTS.filter(
    product => categoryFilter === "All" || product.category === categoryFilter
  ).sort((a, b) => {
    let comparison = 0;

    switch (sortColumn) {
      case "name":
        comparison = a.name.localeCompare(b.name);
        break;
      case "brand":
        comparison = a.brand.localeCompare(b.brand);
        break;
      case "category":
        comparison = a.category.localeCompare(b.category);
        break;
      case "weight":
        comparison = parseFloat(a.weight) - parseFloat(b.weight);
        break;
      case "price":
        comparison = parseFloat(a.price.replace("$", "")) - parseFloat(b.price.replace("$", ""));
        break;
      case "rating":
        comparison = a.rating - b.rating;
        break;
    }

    return sortDirection === "asc" ? comparison : -comparison;
  });

  const SortHeader = ({ column, children }: { column: SortColumn; children: React.ReactNode }) => (
    <th onClick={() => handleSort(column)} className="sortable-header">
      <div className="flex items-center gap-1.5">
        {children}
        <span className="sort-indicator">
          {sortColumn === column ? (
            sortDirection === "asc" ? "▲" : "▼"
          ) : (
            <span className="sort-inactive">⬍</span>
          )}
        </span>
      </div>
    </th>
  );

  const filterBar = (
    <div className="flex items-center gap-2">
      <span className="text-sm text-slate">Category:</span>
      <LinearSelect
        value={categoryFilter}
        onChange={(e) => setCategoryFilter(e.target.value)}
      >
        {categories.map(cat => (
          <option key={cat} value={cat}>{cat}</option>
        ))}
      </LinearSelect>
    </div>
  );

  return (
    <AppShell
      tabs={tabs}
      pageTitle="Product Catalog"
      pageDescription="Browse and compare hiking gear across multiple categories"
      filterBar={filterBar}
    >
      <div className="ui-page">
        <div className="ui-card">
          <table className="product-table">
            <thead>
              <tr>
                <SortHeader column="name">Product</SortHeader>
                <SortHeader column="brand">Brand</SortHeader>
                <SortHeader column="category">Category</SortHeader>
                <SortHeader column="weight">Weight</SortHeader>
                <SortHeader column="price">Price</SortHeader>
                <SortHeader column="rating">Rating</SortHeader>
              </tr>
            </thead>
            <tbody>
              {filteredProducts.map((product) => (
                <tr key={product.id}>
                  <td>
                    <Link href={`/products/${product.id}`} className="product-link">
                      {product.name}
                    </Link>
                  </td>
                  <td className="text-slate">{product.brand}</td>
                  <td>
                    <span className="mono text-sm">{product.category}</span>
                  </td>
                  <td className="mono">{product.weight}</td>
                  <td className="text-slate">{product.price}</td>
                  <td>
                    <span className="rating">
                      ★ {product.rating.toFixed(1)}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AppShell>
  );
}
