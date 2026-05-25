# 🎮 Zuma Game — x86 Assembly (Irvine32)

A playable Zuma-inspired arcade game built entirely in **x86 Assembly language** using the **Irvine32 library** and the **MASM assembler**. The player controls a directional cannon that rotates in 8 directions and shoots marbles across the arena.

> Built as the COAL (Computer Organization & Assembly Language) semester project at FAST University NUCES, Fall 2024.

---

## 🕹️ Controls

| Key | Action |
|-----|--------|
| `W` | Aim Up |
| `X` | Aim Down |
| `A` | Aim Left |
| `D` | Aim Right |
| `Q` | Aim Up-Left (diagonal) |
| `E` | Aim Up-Right (diagonal) |
| `Z` | Aim Down-Left (diagonal) |
| `C` | Aim Down-Right (diagonal) |
| `Space` | Shoot fireball |
| `ESC` | Pause / Exit |

---

## ✨ Features

- 🔫 **8-directional cannon** — rotate in all cardinal + diagonal directions using QWEADZXC keys
- 💥 **Animated fireball** — `*` projectile travels in the aimed direction with 50ms delay per frame, erased and redrawn for smooth animation
- 🧱 **Walled arena** — 25×80 character play area with score, lives, and level HUD drawn at the top
- 👾 **Multi-sprite player** — distinct 3×3 ASCII sprites for each of the 8 aim directions (e.g. ` O-` for right, ` | ` above ` O ` for up, ` /` for up-right, etc.)
- 📊 **HUD** — live score (blue), lives (red), and level number displayed above the arena
- 🔄 **Recursive movement loop** — `MovePlayer` is self-recursive; it re-calls itself after each valid input to maintain a continuous game loop
- 🎨 **Irvine32 color system** — `SetTextColor`, `Gotoxy`, `WriteChar`, and `mWrite` macros used throughout

---

## 📁 Project Structure

```
zuma-assembly/
├── zuma.asm          # Main game — player, fireball, arena, HUD
├── skeletoncode.asm  # Original instructor skeleton (reference)
├── Irvine32.lib          # Irvine32 static library  ← add manually
├── Irvine32.inc          # Irvine32 include file    ← add manually
├── macros.inc            # mWrite macro             ← add manually
├── .gitignore
└── README.md
```

> **Note:** `Irvine32.lib`, `Irvine32.inc`, and `macros.inc` are not included in this repo — download them from the official Irvine32 setup (see below).

---

## ⚙️ Setup & How to Run

### Prerequisites
- **Visual Studio 2019 or 2022** with the **Desktop Development with C++** workload
- **MASM** (included with Visual Studio C++ tools)
- **Irvine32 library** — [Official setup guide](http://asmirvine.com/gettingStartedVS2019/index.htm)

### Steps

1. **Clone the repo:**
   ```bash
   git clone https://github.com/Abdullah-07s/zuma-assembly.git
   ```

2. **Install Irvine32:**
   - Follow the [Irvine32 VS2019 guide](http://asmirvine.com/gettingStartedVS2019/index.htm)
   - Copy `Irvine32.inc`, `Irvine32.lib`, and `macros.inc` into the project root folder

3. **Create a MASM project in Visual Studio:**
   - File → New → Project → **Empty Project** (C++)
   - Right-click project → Build Dependencies → Build Customizations → tick **masm**
   - Add `src/zuma.asm` to Source Files
   - Project Properties → Linker → Input → Additional Dependencies → add `Irvine32.lib`
   - Set to **32-bit** (x86) platform

4. **Build & Run:**
   - Press `Ctrl+F5` to build and run

---

## 🧠 Technical Highlights

### Player Sprite System
Each direction has a unique 3-line × 4-char ASCII sprite stored in `.data`. `PrintPlayer` loads the correct `offset` based on the `direction` byte and prints it row by row using `Gotoxy` + `WriteChar`:

```asm
player_right  BYTE "   ", 0
              BYTE " O-", 0    ; frog facing right
              BYTE "   ", 0

player_upright BYTE "  /", 0
               BYTE " O ", 0   ; frog aiming diagonally
               BYTE "   ", 0
```

### Fireball Animation
`FireBall` computes the starting position and direction vector (`xDir`, `yDir`) based on the current `direction` byte, then loops — drawing `*`, delaying 50ms, erasing with space, and advancing by `(xDir, yDir)` — until it hits a wall boundary:

```asm
fire_loop:
    L1:
        cmp dl, 20    ; left wall
        jle end_fire
        cmp dh, 5     ; top wall
        jle end_fire
        ; ... draw * → delay 50ms → erase → move → repeat
        jmp L1
```

### 8-Directional Movement
Direction vectors for all 8 diagonals are stored as signed bytes (`xDir`, `yDir`). For example, `fire_downright` sets `xDir = 1`, `yDir = 1` — the fireball then advances by `add dl, xDir` / `add dh, yDir` each frame.

### HUD Rendering
`DrawWall` clears the screen, then renders Score (blue), Lives (red), Level number, and the 25-row arena by iterating over the `walls` string array with a nested counter loop.

---

## 🎓 Course Info

> **Course:** Computer Organization & Assembly Language (EE-2003)
> **University:** FAST University NUCES, Islamabad
> **Semester:** Fall 2024 (Semester 5)

---

## 📄 License

Educational use only.
