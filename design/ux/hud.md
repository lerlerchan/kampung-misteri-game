# Kampung Misteri HUD

## Layout (1280 × 720)

- Keep the complete HUD inside the top strip, y=0–104. The board begins at y=112, leaving an 8 px breathing gap.
- Three large plant cards sit across the left and middle of the bar in balance-data order: **Pokok Pisang · 50 sen**, **Pokok Kelapa · 100 sen**, and **Durian · 50 sen**. Each card includes its numeric shortcut (1, 2, 3), Malay name, and cost with the word “sen”; a selected card has a thick bright outline and a small “DIPILIH” tag. Unaffordable cards stay legible but appear muted and disabled.
- Put the sen counter at the right end in a high-contrast coin-shaped badge, e.g. “● 125 sen”. Its text label and number carry the meaning independently of the coin icon.
- Place the wave label below/alongside the sen badge without entering the board: “Gelombang 2 / 5”. At the opening state show “Bersedia · Gelombang 0 / 5”.
- On game end, overlay a broad, centered banner over the playfield: “Kampung selamat!” for a win or “Rumah diserang!” for a loss. Keep it visually distinct from the top HUD and readable against a dark translucent backing.

## Interaction and accessibility

- Click/tap a plant card or press **1**, **2**, or **3** to pick Pisang, Kelapa, or Durian respectively. Show the same selection highlight for either input. Pressing a selected card again does not clear it; `select_card("")` clears selection.
- Disabled/too-expensive cards cannot be picked. Always show name and cost as text; do not use color alone to signal selected, affordable, or disabled state.
- Use large readable type, strong light/dark contrast, and distinct card shapes or small letter/number markers. Keep Malay names and numeric costs visible at all times.

## Coloured-shape palette

| Element | Hex | Shape/art cue |
|---|---|---|
| Board grass | `#4E9A52` | Alternating grass greens, with subtle checker contrast |
| Lane stripes | `#D7E8A8` | Pale cream-green horizontal dashes across lanes |
| Rumah kampung | `#8A5638` | Warm timber wall, roof accent `#C85B3C` |
| Pokok Pisang | `#78B84A` | Broad leaf canopy, yellow fruit `#F4C542` |
| Pokok Kelapa | `#2F8F72` | Tall narrow trunk and fronds, coconut `#8A5638` |
| Durian | `#D8A92E` | Round spiky golden-green silhouette |
| Lipas | `#8C4F32` | Small segmented oval, label “Lipas” |
| Biawak | `#526B4B` | Low long body and tail, label “Biawak” |
| Gagak | `#343A46` | Winged silhouette, label “Gagak” |
| Coin / sen | `#F4C542` | Gold circle with dark “25” or “sen” text |

Use a cheerful Malaysian kampung feel: sun-warmed timber, leafy greens, fruit colors, rounded silhouettes, and friendly hand-painted character. Pair every pest silhouette with its Malay name (or a distinct icon/letter marker) and every plant card with its Malay name and cost so hues never carry meaning by themselves.
