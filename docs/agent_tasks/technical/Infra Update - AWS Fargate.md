### Objective

Implement a **split-backend architecture**:

- **Vercel (Next.js)** → UI, routing, SSR, auth
    
- **AWS Fargate (Go API)** → data-heavy endpoints (search/filter)
    
- **AWS RDS (Postgres)** → primary database
    

---

## 1. High-level architecture

Browser  
  ↓  
Vercel (Next.js FE + SSR + Auth)  
  ↓ (SSR data only)  
AWS RDS  
  
Browser  
  ↓ (client fetch)  
AWS Fargate (Go API)  
  ↓  
AWS RDS

---

## 2. Responsibilities

### Vercel (Next.js)

- Page routing (`/products`, `/product/[id]`)
    
- Auth (Auth.js or similar)
    
- SSR data fetching for:
    
    - category schema
        
    - static product metadata
        
- NEVER handles high-frequency filter/search queries
    

---

### AWS Fargate (Go API)

- Owns:
    
    - `/products/search`
        
    - `/products/filter`
        
- Optimised for:
    
    - high-frequency requests
        
    - low latency
        
- Uses persistent DB connections
    

---

## 3. Claude Code implementation plan

---

# PHASE 1 — Define API boundaries

### Task

Define clear separation of endpoints.

### Output

**Vercel (internal only)**

GET /api/categories  
GET /api/product/[id]

**AWS API (public)**

GET /products/search  
GET /products/filter

---

# PHASE 2 — Next.js (Vercel) setup

### Task

Update Next.js app to:

### 1. Server-side fetch (SSR)

For category schema:

// app/products/page.tsx (server component)  
  
const categories = await fetch(process.env.RDS_DIRECT_URL + "/categories")

- Use direct DB access OR lightweight internal API
    
- Cache with:
    

{ next: { revalidate: 300 } }

---

### 2. Client-side fetch for filters

// client component  
  
fetch("https://api.yoursite.com/products/search?filters=...")

- DO NOT call `/api/*` routes
    
- Always call AWS API directly
    

---

### 3. Auth

- Implement via Auth.js
    
- Store session in cookies/JWT
    
- Expose token to client for AWS calls if needed
    

---

# PHASE 3 — Go API (Fargate)

### Tech stack

- Go
    
- net/http or chi router
    
- pgx (NOT database/sql for better pooling)
    

---

### Project structure

/cmd/api/main.go  
/internal/  
  handler/  
  service/  
  db/  
  model/

---

### DB setup

pool, err := pgxpool.New(ctx, DATABASE_URL)

- global pool
    
- reused across requests
    

---

### Endpoint: /products/search

func SearchProducts(w http.ResponseWriter, r *http.Request) {  
    filters := parseFilters(r)  
  
    results, err := db.SearchProducts(ctx, filters)  
  
    json.NewEncoder(w).Encode(results)  
}

---

### Query requirements

- MUST use:
    
    - `search_product_variant` table
        
- MUST:
    
    - avoid joins
        
    - use indexed columns
        
- support:
    
    - multi-select enums
        
    - numeric ranges
        

---

### Example SQL

SELECT *  
FROM search_product_variant  
WHERE category_id = $1  
AND (brand_id = ANY($2))  
AND weight_g <= $3  
ORDER BY weight_g ASC  
LIMIT 50;

---

# PHASE 4 — AWS infrastructure

### Task

Deploy Go API to Fargate

---

### Components

- ECS Cluster (Fargate)
    
- Service (min 1 task)
    
- ALB (public)
    
- Target group → Go container
    
- Security group:
    
    - allow HTTP from internet
        
    - allow DB access to RDS
        

---

### Environment variables

DATABASE_URL=postgres://...  
PORT=8080

---

### Domain

api.yoursite.com → ALB

---

# PHASE 5 — Networking

### Requirements

- RDS + Fargate in same VPC
    
- private subnets preferred
    
- ALB in public subnet
    

---

# PHASE 6 — Remove Vercel BE dependency for search

### Task

- Delete /api/products/search routes from Next.js
    
- Replace all usages with:
    

https://api.yoursite.com/products/search

---

# PHASE 7 — Performance constraints

### Enforce

- p95 < 120ms (no cache)
    
- query time < 50ms
    
- response size < 100kb
    

---

# PHASE 8 — Future (not now)

- Add Redis between API and DB
    
- Add CDN caching
    
- Add query result caching
    

---

## Final expected behavior

### Initial page load

Browser → Vercel → (SSR) → RDS

### Filter interaction

Browser → AWS API → RDS

---

## Key rules (non-negotiable)

- No filter/search queries through Vercel BE
    
- Go API owns all high-frequency reads
    
- Use connection pooling in Go
    
- Use denormalised search table