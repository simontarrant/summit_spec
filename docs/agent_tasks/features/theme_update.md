Summit Spec Design System
Purpose

This document defines the visual design system for Summit Spec.

Summit Spec is a technical gear specification platform for ultralight hiking equipment.
The UI must prioritize:

data readability

fast comparison

technical clarity

low visual noise

The product should feel like a precision engineering tool, not a marketing website.

Think:

alpine expedition equipment

topographic maps

engineering dashboards

spec sheets

terminal interfaces

Core Visual Principles
1. Data Is The Interface

Specifications and comparisons are the primary content.

The UI should prioritize:

product name

spec values

comparison tables

filters

Everything else should be visually secondary.

Avoid:

oversized hero elements

marketing cards

unnecessary whitespace

Color System

The palette should evoke alpine terrain.

Think:

granite

ice

snow

forest

alpine sky

Base Colors

Background hierarchy:

--color-bg-primary     #0F1112   // page background
--color-bg-surface     #171A1C   // cards / panels
--color-bg-elevated    #1F2428   // dropdowns / modals
Border Colors
--color-border-subtle  #2A2F33
--color-border-strong  #3B4247
Text Colors
--color-text-primary   #E6E8EA
--color-text-secondary #A7AFB5
--color-text-muted     #6B7378

Text should never be pure white.

Accent Colors

Accent colors represent gear categories and highlight states.

Primary accent:

--color-accent-alpine   #3F7A66

Secondary accents:

--color-accent-sky      #4C7EA6
--color-accent-amber    #C9853B

Usage rules:

Alpine green → primary UI accent

Sky blue → informational highlights

Amber → warnings / callouts

Never overuse accent colors.

Typography

Typography must feel precise and technical.

Primary Font
Inter

Usage:

UI text

labels

headings

Data Font

Use tabular numbers where possible.

Numbers should align vertically.

Example:

font-variant-numeric: tabular-nums;
Type Scale

Use restrained hierarchy.

H1  28px   page title
H2  22px   section title
H3  18px   subsection
Body 14px  standard UI text
Data 13px  table values
Meta 12px  labels / units

Avoid large typography.

Layout System

Spacing should feel tight and technical, not airy.

Spacing scale:

4px   micro
8px   tight
12px  compact
16px  normal
24px  section
32px  major

Prefer 12–16px spacing for most UI elements.

Surface Design

Surfaces should feel flat and engineered.

Avoid:

heavy shadows

gradients

neumorphism

Prefer:

subtle borders

flat panels

layered surfaces

Example:

background: var(--color-bg-surface)
border: 1px solid var(--color-border-subtle)
border-radius: 6px
Table Design (CRITICAL)

Tables are the most important UI component.

All spec tables must follow these rules.

Table Layout

Structure:

Attribute | Product A | Product B | Product C

First column:

attribute name

sticky when scrolling

Table Styling

Header row:

background: var(--color-bg-elevated)
font-weight: 600

Rows:

border-bottom: 1px solid var(--color-border-subtle)

Hover state:

background: rgba(255,255,255,0.03)
Numeric Alignment

Numbers should always be:

text-align: right
font-variant-numeric: tabular-nums

Units should be visually secondary.

Example:

430 g

Where g is muted.

Attribute Display

Attributes should feel like structured engineering data.

Example:

Weight        430 g
R Value       4.5
Length        183 cm
Thickness     7.5 cm

Use:

consistent alignment

consistent units

no unnecessary labels

Filters UI

Filters should feel like instrument controls, not ecommerce widgets.

Use:

compact dropdowns

checkboxes

numeric sliders

Spacing should be tight.

Example:

R Value
[ 3.0 —— 7.0 ]

Weight
[ 300g —— 700g ]
Buttons

Buttons should be minimal and functional.

Primary button:

background: var(--color-accent-alpine)
color: white

Secondary button:

background: transparent
border: 1px solid var(--color-border-strong)

Hover states should be subtle.

Badges

Badges are used for:

category

brand

features

Example:

ULTRALIGHT
AIR PAD
FOAM PAD

Badge style:

background: var(--color-bg-elevated)
border: 1px solid var(--color-border-subtle)
font-size: 12px
Product Cards

Cards should be dense and information-focused.

Structure:

Product Name
Brand

Key Specs Row
Weight   R Value   Thickness

Mini attribute table

Avoid large product imagery dominating the card.

Navigation

Navigation should feel like a technical control panel.

Top bar:

Summit Spec
Categories
Compare
Search

Minimal styling.

Focus should remain on the data.

Icons

Icons should be:

outline style

minimal

monochrome

Suggested icon set:

Lucide

Avoid colorful icons.

Interaction Design

Interactions should be fast and subtle.

Hover:

background change only

Avoid:

bounce

exaggerated animation

playful effects

What the UI Should Feel Like

Summit Spec should feel like:

an alpine expedition database

an engineer’s spec sheet

a professional gear comparison tool

Users should feel like they are working with precision data, not browsing content.

What the UI Should NOT Feel Like

Avoid looking like:

an ecommerce storefront

a marketing site

a lifestyle outdoor blog

Summit Spec is a tool, not a store.

Implementation Instructions

Claude should:

Implement theme variables in globals.css

Update Tailwind usage to reference theme tokens

Improve table styling across the app

Refactor component styling

Maintain all existing functionality

No business logic should change.