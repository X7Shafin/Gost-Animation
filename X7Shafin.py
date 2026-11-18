#!/usr/bin/env python3
# X7Shafin.py - SHAFIN KHAN | X7Shafin

import sys
import time
import random
import shutil

NAME = ["SHAFIN", "KHAN"]
BRAND = "X7Shafin"
TELEGRAM = "https://t.me/GhostX_Hacker"
FACEBOOK = "https://www.facebook.com/share/1E8gkJwn2c/"

GREENS = ["#00ff41", "#00e63a", "#00cc33", "#00b32b", "#009924", "#00801e"]
FONTS = ["small", "standard", "slant", "big", "doom", "mini", "digital"]

# Built-in art, so the banner never depends on pyfiglet
ART = {
    "SHAFIN": [
        r" ___ _  _   _   ___ ___ _  _ ",
        r"/ __| || | /_\ | __|_ _| \| |",
        r"\__ \ __ |/ _ \| _| | || .` |",
        r"|___/_||_/_/ \_\_| |___|_|\_|",
    ],
    "KHAN": [
        r" _  _ _  _   _   _  _ ",
        r"| |/ / || | /_\ | \| |",
        r"| ' <| __ |/ _ \| .` |",
        r"|_|\_\_||_/_/ \_\_|\_|",
    ],
}

ANIMATE = True

try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.text import Text
    from rich.align import Align
    from rich import box
    c = Console()
except ImportError:
    # Plain fallback: no crash, no traceback
    print("SHAFIN KHAN | " + BRAND)
    print(TELEGRAM)
    print(FACEBOOK)
    sys.exit(0)


def rgb(hex_color, bold=False):
    h = hex_color.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return ("\033[1;" if bold else "\033[") + f"38;2;{r};{g};{b}m"


RESET = "\033[0m"


def boot():
    steps = [
        "Initializing Termux",
        "Loading modules",
        "Bypassing firewall",
        "Access granted",
    ]
    for s in steps:
        c.print(f"[bold green][+][/] [green]{s}[/]", end="")
        for _ in range(3):
            time.sleep(0.12)
            c.print("[green].[/]", end="")
        c.print(" [bold #00ff41]OK[/]")
    c.print()


def banner():
    i = 0
    for word in NAME:
        lines = ART[word]
        width = max(len(x) for x in lines)
        for line in lines:
            color = GREENS[min(i, len(GREENS) - 1)]
            c.print(
                Align.center(Text(line.ljust(width), style=f"bold {color}")),
                highlight=False,
            )
            i += 1
    c.print()

    info = Text()
    info.append("[DEV]    ", style="bold #00ff41")
    info.append(" ".join(NAME) + "\n", style="bold white")
    info.append("[BRAND]  ", style="bold #00ff41")
    info.append(BRAND + "\n", style="white")
    info.append("[TG]     ", style="bold #00ff41")
    info.append(TELEGRAM + "\n", style="underline cyan")
    info.append("[FB]     ", style="bold #00ff41")
    info.append(FACEBOOK, style="underline cyan")

    panel = Panel(
        info,
        box=box.DOUBLE,
        border_style="green",
        title=f"[bold #00ff41]< {BRAND} >[/]",
        subtitle=f"[#ffdd33]Powered by {BRAND}[/]",
        width=min(c.width, 58),
    )
    c.print(Align.center(panel))
    c.print()
    welcome()


def welcome():
    msg = f"Welcome to {BRAND}"
    n = len(msg)
    pool = "01#$%&@*+=<>?/|"
    prefix = "░▒▓ 👻 "
    suffix = " ▓▒░"
    total = 7 + n + 4  # visible width: prefix(7) + message + suffix(4)
    width = shutil.get_terminal_size((60, 20)).columns
    pad = " " * max(0, (width - total) // 2)

    def render(done, glow=-10):
        out = rgb("#00801e") + prefix
        for i, ch in enumerate(msg):
            color = GREENS[i * len(GREENS) // n]
            if ch == " ":
                out += " "
            elif abs(i - glow) <= 1:
                out += rgb("#ffffff", True) + ch
            elif i < done:
                out += rgb(color, True) + ch
            elif i < done + 5:
                out += rgb("#00ff41") + random.choice(pool)
            else:
                out += " "
        return out + rgb("#00801e") + suffix + RESET

    def show(done, glow=-10):
        sys.stdout.write("\r" + pad + render(done, glow))
        sys.stdout.flush()

    if ANIMATE:
        for d in range(n + 1):
            show(d)
            time.sleep(0.07)
        for g in range(-1, n + 2):
            show(n, g)
            time.sleep(0.03)
    show(n)
    sys.stdout.write("\n")
    c.print(Align.center(Text("─" * 20, style="#00801e")))
    c.print()


def stylize(text):
    try:
        import pyfiglet
    except ImportError:
        c.print(text, style="bold green", markup=False)
        return
    font = random.choice(FONTS)
    try:
        lines = pyfiglet.figlet_format(text, font=font).rstrip("\n").split("\n")
    except Exception:
        lines = [text]
    for i, line in enumerate(lines):
        color = GREENS[i % len(GREENS)]
        c.print(line, style=f"bold {color}", markup=False, highlight=False)
    c.print()


def main():
    global ANIMATE
    args = sys.argv[1:]
    quiet = "-q" in args
    ANIMATE = "-n" not in args
    args = [a for a in args if a not in ("-q", "-n")]

    if not quiet:
        boot()
    banner()
    if args:
        stylize(" ".join(args))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
