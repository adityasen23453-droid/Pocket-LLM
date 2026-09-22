# PocketLLM Design System & Interface Architecture (`design.md`)

## 1. Overview
PocketLLM is an executive, private on-device AI workspace engineered with a luxury high-fashion editorial aesthetic. The interface is styled with a unified **Warm Editorial Cream & Forest Emerald** theme across all pages, matching the brand identity established on the initial landing page.

---

## 2. Color Palette & Theming Tokens

### Light Theme (Warm Editorial Cream & Forest Emerald)
| Token | Hex Value | Purpose |
|---|---|---|
| `scaffoldBg` | `#F7F4EE` | Warm linen / editorial cream canvas |
| `gridLine` | `rgba(223, 205, 188, 0.35)` | Subtle travertine diamond lattice grid lines |
| `surfaceCard` | `#FAF7F0` / `#FFFFFF` | Frosted travertine card surfaces with `#EDE8DC` borders |
| `headlineEmerald` | `#172C1E` / `#1B4329` | Deep luxury Forest Emerald display accent (`AI Enables`, `& Voice`) |
| `headlineDark` | `#14261A` | Deep forest charcoal for display headline (`Smooth Assistant`, `Interaction`) |
| `bubbleUserPrimary` | `#172C1E` | Deep Forest Emerald gradient start for user speech bubble |
| `bubbleUserSecondary` | `#2A5338` | Emerald gradient end for user speech bubble |
| `rainbowBorder` | `#A6D4B0` → `#D4AF37` → `#8BB596` → `#2E6F45` | Champagne gold & emerald sage gradient border |
| `pillInactiveBg` | `#FAF7F0` | Pill chip warm ivory background |
| `pillInactiveBorder` | `rgba(223, 205, 188, 0.35)` | Delicate travertine hairline boundary |
| `pillActiveBorder` | `#172C1E` | Selected pill chip forest emerald border & text |
| `actionIconMuted` | `#767B76` | Message action icons (`[Copy] [Like] [Speaker]`) |

### Dark Theme (Deep Forest Obsidian & Luminous Mint)
| Token | Hex Value | Purpose |
|---|---|---|
| `scaffoldBg` | `#101211` | Deep forest obsidian canvas with ambient depth |
| `gridLine` | `rgba(139, 181, 150, 0.05)` | Faint luminous emerald diamond lattice lines |
| `surfaceCard` | `#181B19` | High-contrast dark forest cards with hairline borders |
| `inputInterior` | `#181B19` | Deep obsidian card inside rainbow border |
| `headlineEmerald` | `#8BB596` / `#A6D4B0` | Radiant luminous mint sage accent |
| `headlineLight` | `#F7F4EE` | Warm alabaster white for display headline |
| `rainbowBorder` | `#3F6649` → `#10B981` → `#D4AF37` → `#8BB596` | Luminous emerald & gold gradient border |
| `bubbleGlow` | `rgba(16, 185, 129, 0.16)` / `rgba(139, 181, 150, 0.12)` | Dual-bloom emerald aura behind 3D bubble |
| `pillInactiveBg` | `#181B19` | Dark frosted pill card |
| `pillInactiveBorder` | `rgba(255, 255, 255, 0.12)` | Delicate hairline boundary |
| `actionIconMuted` | `#ACAFAB` | Refined titanium muted icon tint |

---

## 3. Typography Scale & Layout Hierarchy

PocketLLM utilizes a clean geometric sans-serif hierarchy paired with high-contrast dual-tone headlines:

| Element | Font Family | Size | Weight | Tracking / Line Height | Color (Light / Dark) |
|---|---|---|---|---|---|
| Display Headline 1 | Sans-Serif | 24px | Bold (`w800`) | `-0.5` / `1.25` | `#172C1E` & `#14261A` / `#8BB596` & `#F7F4EE` |
| Filter Pill Label | Sans-Serif | 13.5px | Semi-Bold (`w600`) | `-0.1` | `#14261A` / `#F7F4EE` |
| User Bubble Text | Sans-Serif | 14.5px | Medium (`w400`) | `-0.1` / `1.4` | `#F7F4EE` |
| AI Bubble Text | Sans-Serif | 14.5px | Regular (`w400`) | `-0.1` / `1.45` | `#14261A` / `#F7F4EE` |
| Input Placeholder | Sans-Serif | 15.5px | Regular (`w400`) | `-0.2` | `#767B76` / `#7E827E` |
| Timestamp Labels | Sans-Serif | 11.5px | Regular (`w400`) | `0.0` | `#767B76` / `#8BB596` |

---

## 4. Visual Components & Centerpiece Assets

### A. Top Navigation Bar
- **Left Circular Button (42×42)**:
  - Floating circular button (`#FAF7F0` in light, `#181B19` in dark) with `#EDE8DC` border and soft ambient drop shadow.
  - State adaptive: Hamburger `☰` on home; Close `✕` during active chat.
- **Center Brand Icon (34×34)**:
  - 3D Liquid Chrome "C" Icon (`assets/images/chrome_logo_icon.png`).
- **Right Theme & Session Controls**:
  - **Theme Toggle Button (`☀️ / 🌙`)**: Instantly flips between light cream and dark obsidian modes.
  - **History Receipt Button**: Shown during active conversation to open session history drawer.

### B. Empty State Centerpiece
- **Two-Tone Gradient Headline**:
  - `AI Enables ` (Forest Emerald) `Smooth Assistant\n` (Charcoal / Alabaster) `& Voice ` (Forest Emerald) `Interaction`.
- **3D Emerald Crystal Soap Bubble (`assets/images/emerald_glass_bubble.png`)**:
  - 250×250 crystal soap bubble with deep forest emerald, luminous mint, and gold reflections, glowing central microphone, and floor reflection.
  - In dark mode, backed by dual emerald & mint radial blooms (`#10B981` and `#8BB596`).
- **Filter Chips Position**:
  - Positioned directly above `ChatInput` with `6px` spacing: `[ 📄 Docs ]`, `[ 🖼️ Images ]`, `[ 📊 Sheets ]`, `[ 💻 Code ]`.

### C. Floating Champagne & Emerald Gradient Chat Input
- 2.0px champagne gold & emerald gradient stroke wrapping the composite card.
- Adaptive interior card (`#FAF7F0` in light, `#181B19` in dark).
- Action controls: attachment button `(🔗)`, `[ ✦ Voice ]` pill, and solid Forest Emerald `[ ✈ Send ]` button (`#172C1E` to `#2A5338`).

### D. Conversation Stream Architecture
- **User Messages**: Solid Forest Emerald bubble (`#172C1E` to `#2A5338`) with right-aligned timestamp below.
- **AI Messages**: Left-aligned with 34×34 3D Emerald Bubble avatar, adaptive card (`#FFFFFF` / `#181B19`), and bottom action row (`[Copy] [Like] [Speaker]`).
