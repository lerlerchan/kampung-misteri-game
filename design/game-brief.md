# Kampung Misteri — Game Brief (v1)

Full plan: Obsidian vault `outputs/2026-11-05-kampung-misteri-game-plan.md`.
All numbers live in `assets/data/balance.json`. This brief names keys; it does not repeat values.

## Overview

A 2D lane-defense game set in a Malaysian kampung. The player plants kampung
plants on a grid to stop cute pests (lipas, gagak, biawak) reaching the rumah kampung.
Version 1 is one level with five waves.

## Player Fantasy

Protecting your grandparents' kampung house with the garden itself: banana trees
that pay for everything, coconut trees that lob coconuts, and a durian nobody wants to bite.

## Core Loop

1. Collect sen coins (from the sky and from Pokok Pisang).
2. Pick a plant card (click or keys 1/2/3).
3. Click an empty grid cell to plant it.
4. Plants hold the lanes while the next wave arrives.

## Rules

- **Board:** `board.lanes` x `board.cols` grid. House on the left; pests enter on the right.
- **Sen:** start with `economy.start_sen`. A sky coin falls every `economy.sky_coin_every` s.
  Each coin is worth `economy.coin_value`. Click a coin to collect it.
- **Plants** (`plants.*`): one per cell, paid with `cost`.
  - Pokok Pisang drops a coin every `coin_every` s.
  - Pokok Kelapa shoots `shot_damage` every `shot_every` s, only when a pest is in its lane.
  - Durian is a wall with high `hp`. Each bite costs the biter `thorns` damage.
- **Pests** (`pests.*`): walk left at `speed`. When blocked, bite the plant for `bite` per second.
  - Gagak hops over the first `hops` plant(s) it meets.
  - A defeated pest runs off to the right and fades out (chased away, not killed).
- **Waves** (`waves.*`): first wave after `first_delay` s, then `gap` s between waves.
  One pest every `spawn_every` s. Lanes are random from `seed` (same seed, same waves).

## Win / Lose

- **Lose:** any pest reaches the house edge. Banner: "Rumah diserang!"
- **Win:** all waves have spawned and no pests are left. Banner: "Kampung selamat!"

## Tuning Knobs

`board.*`, `economy.*`, `plants.<kind>.*`, `pests.<kind>.*`, `waves.*`, `fx.*` (animation timing only)
in `assets/data/balance.json`.

## Out of Scope v1

Main menu, more levels, unlocks, save, sound, real art, mobile/web export,
last-line defender per lane.

## Acceptance Criteria

- [x] `tests/unit/rules/test_rules.gd` passes (cost, damage, seeded waves, grid maths).
- [x] Unattended play: a pest reaches the house and the lose banner shows
      (`production/qa/evidence/2026-11-05-kampung-lose.png`).
- [x] 3 kelapa + 1 durian per lane clear all 5 waves and the win banner shows
      (`tests/integration/autoplay/autoplay_win.gd`, `production/qa/evidence/2026-11-05-kampung-win.png`).
- [ ] Human playtest: starting from 50 sen, a player can win by hand. Is it fun?
