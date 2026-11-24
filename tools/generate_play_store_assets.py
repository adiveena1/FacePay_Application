import os
from PIL import Image, ImageDraw, ImageFont

def create_feature_graphic():
    width = 1024
    height = 500
    img = Image.new("RGB", (width, height), color=(11, 17, 32))
    draw = ImageDraw.Draw(img)

    # Draw gradient-like background glow
    for r in range(350, 0, -5):
        alpha = int(25 * (1 - r / 350))
        color = (14 + alpha, 165 // 4 + alpha, 233 // 3 + alpha)
        draw.ellipse([width//2 - r, height//2 - r, width//2 + r, height//2 + r], fill=color)

    # Top border accent bar
    for x in range(width):
        r = int(14 + (99 - 14) * (x / width))
        g = int(165 + (102 - 165) * (x / width))
        b = int(233 + (241 - 233) * (x / width))
        draw.line([(x, 0), (x, 4)], fill=(r, g, b))

    # Center Logo Badge (rounded rect)
    logo_size = 96
    cx, cy = width // 2, 130
    draw.rounded_rectangle([cx - logo_size//2, cy - logo_size//2, cx + logo_size//2, cy + logo_size//2], radius=24, fill=(14, 165, 233))
    
    # Shield / Face representation inside logo badge
    draw.rectangle([cx - 20, cy - 20, cx + 20, cy + 20], outline=(255, 255, 255), width=3)
    draw.ellipse([cx - 10, cy - 8, cx - 4, cy - 2], fill=(255, 255, 255))
    draw.ellipse([cx + 4, cy - 8, cx + 10, cy - 2], fill=(255, 255, 255))
    draw.arc([cx - 10, cy - 2, cx + 10, cy + 12], start=20, end=160, fill=(255, 255, 255), width=3)

    # Typography
    try:
        font_large = ImageFont.truetype("arialbd.ttf", 46)
        font_sub = ImageFont.truetype("arial.ttf", 20)
        font_pill = ImageFont.truetype("arialbd.ttf", 14)
        font_small = ImageFont.truetype("arial.ttf", 13)
    except:
        font_large = ImageFont.load_default()
        font_sub = ImageFont.load_default()
        font_pill = ImageFont.load_default()
        font_small = ImageFont.load_default()

    # Title
    title = "FacePay"
    bbox = draw.textbbox((0, 0), title, font=font_large)
    t_w = bbox[2] - bbox[0]
    draw.text(((width - t_w) // 2, 205), title, fill=(255, 255, 255), font=font_large)

    # Subtitle
    subtitle = "On-Device Facial Liveness Verification for High-Value UPI Payments"
    s_bbox = draw.textbbox((0, 0), subtitle, font=font_sub)
    s_w = s_bbox[2] - s_bbox[0]
    draw.text(((width - s_w) // 2, 270), subtitle, fill=(148, 163, 184), font=font_sub)

    # Feature Badges / Pills
    pills = [
        ("₹500 Threshold Rule", (16, 185, 129)),
        ("Google ML Kit On-Device", (14, 165, 233)),
        ("100% Privacy Preserving", (99, 102, 241)),
        ("Cloud Firestore Sync", (245, 158, 11))
    ]
    
    total_pill_width = sum(len(p[0]) * 9 + 36 for p in pills) + (len(pills) - 1) * 16
    start_x = (width - total_pill_width) // 2
    cur_x = start_x
    pill_y = 330
    pill_h = 36

    for text, color in pills:
        pw = len(text) * 9 + 36
        draw.rounded_rectangle([cur_x, pill_y, cur_x + pw, pill_y + pill_h], radius=18, fill=(20, 30, 48), outline=color, width=2)
        # Small status dot
        draw.ellipse([cur_x + 12, pill_y + 13, cur_x + 22, pill_y + 23], fill=color)
        draw.text((cur_x + 28, pill_y + 9), text, fill=(241, 245, 249), font=font_pill)
        cur_x += pw + 16

    # Bottom academic / author footer
    footer = "Aditya Veena Maharaj (2024424251) & Gaurav Mudgal (2024278918) | Guided by Dr. Gaurav Raj"
    f_bbox = draw.textbbox((0, 0), footer, font=font_small)
    f_w = f_bbox[2] - f_bbox[0]
    draw.text(((width - f_w) // 2, 440), footer, fill=(100, 116, 139), font=font_small)

    out_path = os.path.join("play_store_assets", "feature_graphic_1024x500.png")
    img.save(out_path, "PNG")
    print(f"Generated feature graphic: {out_path} ({width}x{height})")

def create_play_store_screenshots():
    # Load base emulator screenshot
    base_path = "emulator_screenshot_live.png"
    if not os.path.exists(base_path):
        print(f"Base screenshot {base_path} not found.")
        return

    base_img = Image.open(base_path)
    # Target Play Store phone screenshot canvas: 1080 x 2280
    canvas_w, canvas_h = 1080, 2280

    screens_data = [
        ("Secure Digital Wallet", "Personalized UPI Dashboard & Instant Overview", (14, 165, 233)),
        ("₹500 Threshold Rule", "Micro-payments bypass camera. Payments > ₹500 enforce biometrics.", (16, 185, 129)),
        ("On-Device ML Kit Face Verification", "Active anti-spoofing via randomized eye-blinks & head-turns.", (99, 102, 241)),
        ("Real-Time Cloud Firestore Sync", "Live transaction audit trail and security streak achievements.", (245, 158, 11))
    ]

    try:
        font_header = ImageFont.truetype("arialbd.ttf", 52)
        font_desc = ImageFont.truetype("arial.ttf", 26)
    except:
        font_header = ImageFont.load_default()
        font_desc = ImageFont.load_default()

    # Resize base image to fit nicely inside canvas phone frame
    target_phone_w = 840
    ratio = target_phone_w / base_img.width
    target_phone_h = int(base_img.height * ratio)
    phone_resized = base_img.resize((target_phone_w, target_phone_h), Image.Resampling.LANCZOS)

    for i, (title, desc, accent) in enumerate(screens_data, 1):
        canvas = Image.new("RGB", (canvas_w, canvas_h), color=(11, 17, 32))
        draw = ImageDraw.Draw(canvas)

        # Gradient top glow
        for r in range(400, 0, -10):
            alpha = int(20 * (1 - r / 400))
            draw.ellipse([canvas_w//2 - r, 100 - r, canvas_w//2 + r, 100 + r], fill=(accent[0]//5 + alpha, accent[1]//5 + alpha, accent[2]//5 + alpha))

        # Title
        t_box = draw.textbbox((0, 0), title, font=font_header)
        draw.text(((canvas_w - (t_box[2]-t_box[0])) // 2, 110), title, fill=(255, 255, 255), font=font_header)

        # Description
        d_box = draw.textbbox((0, 0), desc, font=font_desc)
        draw.text(((canvas_w - (d_box[2]-d_box[0])) // 2, 190), desc, fill=(148, 163, 184), font=font_desc)

        # Phone frame positioning
        px = (canvas_w - target_phone_w) // 2
        py = 280

        # Phone outer shadow / border
        draw.rounded_rectangle([px - 6, py - 6, px + target_phone_w + 6, py + target_phone_h + 6], radius=32, fill=(30, 41, 59), outline=accent, width=3)
        canvas.paste(phone_resized, (px, py))

        out_name = os.path.join("play_store_assets", f"screenshot_{i}_{title.lower().replace(' ', '_')}.png")
        canvas.save(out_name, "PNG")
        print(f"Generated Play Store screenshot: {out_name}")

if __name__ == "__main__":
    create_feature_graphic()
    create_play_store_screenshots()
