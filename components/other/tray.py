"""
tray_clipboard_viewer.py

Pure-Python tray icon for launching batch files.
Required pip packages: 
-pystray
-pillow
"""

import os
import sys
import subprocess
import threading
from pathlib import Path

from PIL import Image, ImageDraw

import pystray
from pystray import MenuItem as Item, Menu as Menu

# ---------- Helpers ----------

def script_dir():
    # directory of this script (similar to $PSScriptRoot)
    if getattr(sys, "frozen", False):
        # when frozen by pyinstaller
        return Path(sys._MEIPASS)
    return Path(__file__).resolve().parent

def start_batch(batch_path):
    """
    Run a batch file normally, with a visible console window.
    The window will close automatically when the batch finishes.
    """
    bp = Path(batch_path)
    if not bp.exists():
        print(f"[tray] Batch file not found: {bp}", file=sys.stderr)
        return

    def worker():
        try:
            subprocess.Popen(
                ["cmd", "/c", str(bp)],
                cwd=str(bp.parent)
            )
        except Exception as e:
            print("[tray] Failed to start batch:", e, file=sys.stderr)

    threading.Thread(target=worker, daemon=True).start()

def ensure_exists_or_exit(p, label: str):
    """
    Accepts a Path or str. Converts to Path and checks existence.
    If missing: print error, wait for keypress, exit(1).
    """
    p = Path(p)
    if not p.exists():
        print(f"{label} not found: {p}", file=sys.stderr)
        try:
            input("press any key to close this script...")
        except Exception:
            pass
        sys.exit(1)

# ---------- Icon creation / loading ----------

def load_icon_image(icon_file, size=(64, 64)):
    """
    Load icon from file. Accept .ico, png etc. If not found or can't load,
    create a simple fallback image.
    Accepts str or Path.
    """
    icon_file = Path(icon_file)
    if icon_file.exists():
        try:
            im = Image.open(icon_file)
            im = im.convert("RGBA")
            im = im.resize(size, Image.LANCZOS)
            return im
        except Exception:
            pass
    # Fallback: draw a simple "picture" glyph
    img = Image.new("RGBA", size, (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    w, h = size
    draw.rectangle((0, 0, w-1, h-1), fill=(60, 60, 60, 255))
    draw.polygon([(6, h-14), (w//2 - 2, h//2), (w-6, h-10)], fill=(200, 200, 200, 255))
    draw.ellipse((w-20, 6, w-8, 14), fill=(250, 200, 0, 255))
    return img

# ---------- Main tray icon logic ----------

def main():
    root = script_dir()
    batch_path = root / "run.bat"
    irfan_batch = root / "run-irfanview.bat"
    icon_file = root / "icon.ico"

    # replicate original tests that exit with keypress if missing
    ensure_exists_or_exit(batch_path, "Batch file")
    ensure_exists_or_exit(irfan_batch, "Batch file")

    image = load_icon_image(icon_file)

    # Menu action functions
    def action_view(icon, item):
        start_batch(batch_path)

    def action_irfan(icon, item):
        start_batch(irfan_batch)

    def action_exit(icon, item):
        try:
            icon.visible = False
        except Exception:
            pass
        icon.stop()

    menu = Menu(
        Item("view clipboard image", action_view, default=True),
        Item("view clipboard image (irfanview)", action_irfan),
        Item("Exit", action_exit)
    )

    icon = pystray.Icon(
        name="clipboard_image_viewer",
        icon=image,
        title="clipboard image viewer",
        menu=menu
    )

    try:
        icon.run()
    except KeyboardInterrupt:
        try:
            icon.visible = False
        except Exception:
            pass

if __name__ == "__main__":
    main()