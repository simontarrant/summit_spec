1. Reduce Vertical Dead Space

Right now the page is too tall before the table starts.

You currently have:

Navbar
Page title
Category row
Filters panel
Spacer
Table

For a data tool, users want the table immediately visible.

Fix

Reduce spacing in three places:

Page header

Current feel:

Product Catalog
Browse and compare hiking gear across categories

Make this more compact.

Example:

Product Catalog   |  Sleeping Pads
Browse and compare hiking gear

Even better: move category into header.

Filter panel

The filter panel height is the biggest offender.

Improvements:

• tighten spacing
• reduce padding
• reduce label font size
• align fields tighter

Goal: 30–40% height reduction.

2. Improve Filter Panel Hierarchy

Right now the filter blocks look visually identical, which reduces scannability.

Current:

Number Filters
Enum Filters
Boolean Filters
String Filters

These labels feel developer-y, not user-y.

Replace with:
Numeric Filters
Attributes
Features
Text Search

Or even better:

Range Filters
Attributes
Features
Search

Cleaner and more product-like.

you can just hardcode this mapping into the FE

3. Improve Numeric Input UX

The current UI:

Min — Max

Looks good but feels slightly empty.

Add subtle unit hints:

Weight (g)
[ min ] — [ max ]

But inside inputs show:

0
1000

instead of blank fields.

It makes the UI feel more engineered.

4. Table Header Contrast

Your table header is too low contrast relative to the body.

The header should act as an anchor for scanning.

Fix

Increase contrast slightly:

Header background:

#1F2428 → #22282D

Add subtle bottom border:

border-bottom: 1px solid #3A4045

This makes the table feel structured.

5. Improve Spec Value Styling

The grey pills for numbers are good but slightly heavy.

Example:

460g
1830mm

They look a bit like tags, not values.

Improve

Option A (better):

Remove pills entirely.

460 g
1830 mm

Right aligned.

This is more technical and less UI clutter.

Right aligned columns make scanning dramatically easier.

7. Filter Toggle UX

Right now:

Hide Filters
Clear Filters

The "Hide Filters" button looks too prominent.

Suggestion:

Make filters a collapsible panel:

Filters ▼

Much cleaner.
