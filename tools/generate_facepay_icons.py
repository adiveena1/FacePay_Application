import os
import math
from PIL import Image, ImageDraw, ImageFont

def create_facepay_icon(size):
    # Create RGBA canvas
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    s = size
    # Outer circle / squircle background: Deep Royal Blue #0D47A1
    # Adding subtle corner margin (5%) for adaptive styling
    margin = int(s * 0.04)
    bbox = [margin, margin, s - margin, s - margin]
    
    # Background rounded rectangle
    corner_radius = int(s * 0.22)
    bg_color = (13, 71, 161, 255) # #0D47A1 Deep Royal Blue
    draw.rounded_rectangle(bbox, radius=corner_radius, fill=bg_color)

    # Inner subtle glow circle
    cx, cy = s // 2, s // 2
    r_face = int(s * 0.26)

    # Draw Biometric Corner Brackets in Cyan (#4FC3F7)
    bracket_color = (79, 195, 247, 255)
    bracket_w = max(2, int(s * 0.035))
    b_len = int(s * 0.14)
    b_margin = int(s * 0.16)

    # Top-Left Bracket
    draw.line([(b_margin, b_margin + b_len), (b_margin, b_margin)], fill=bracket_color, width=bracket_w)
    draw.line([(b_margin, b_margin), (b_margin + b_len, b_margin)], fill=bracket_color, width=bracket_w)

    # Top-Right Bracket
    draw.line([(s - b_margin - b_len, b_margin), (s - b_margin, b_margin)], fill=bracket_color, width=bracket_w)
    draw.line([(s - b_margin, b_margin), (s - b_margin, b_margin + b_len)], fill=bracket_color, width=bracket_w)

    # Bottom-Left Bracket
    draw.line([(b_margin, s - b_margin - b_len), (b_margin, s - b_margin)], fill=bracket_color, width=bracket_w)
    draw.line([(b_margin, s - b_margin), (b_margin + b_len, s - b_margin)], fill=bracket_color, width=bracket_w)

    # Bottom-Right Bracket
    draw.line([(s - b_margin - b_len, s - b_margin), (s - b_margin, s - b_margin)], fill=bracket_color, width=bracket_w)
    draw.line([(s - b_margin, s - b_margin - b_len), (s - b_margin, s - b_margin)], fill=bracket_color, width=bracket_w)

    # Center Face Outline (white, smooth)
    face_color = (255, 255, 255, 255)
    line_w = max(2, int(s * 0.03))

    # Face circle
    face_bbox = [cx - r_face, cy - r_face - int(s * 0.02), cx + r_face, cy + r_face - int(s * 0.02)]
    draw.ellipse(face_bbox, outline=face_color, width=line_w)

    # Eyes
    eye_offset_x = int(r_face * 0.42)
    eye_offset_y = int(r_face * 0.20)
    eye_r = max(2, int(s * 0.035))
    face_center_y = cy - int(s * 0.02)

    # Left eye
    draw.ellipse(
        [cx - eye_offset_x - eye_r, face_center_y - eye_offset_y - eye_r,
         cx - eye_offset_x + eye_r, face_center_y - eye_offset_y + eye_r],
        fill=face_color
    )
    # Right eye
    draw.ellipse(
        [cx + eye_offset_x - eye_r, face_center_y - eye_offset_y - eye_r,
         cx + eye_offset_x + eye_r, face_center_y - eye_offset_y + eye_r],
        fill=face_color
    )

    # Smile / Liveness arc
    smile_w = int(r_face * 0.9)
    smile_h = int(r_face * 0.5)
    smile_bbox = [cx - smile_w // 2, face_center_y - int(r_face * 0.1), cx + smile_w // 2, face_center_y + smile_h]
    draw.arc(smile_bbox, start=25, end=155, fill=face_color, width=line_w)

    # Emerald Green Shield / Checkmark Badge (#00C853) in bottom right corner
    badge_r = int(s * 0.16)
    badge_cx = int(s * 0.76)
    badge_cy = int(s * 0.76)
    badge_bbox = [badge_cx - badge_r, badge_cy - badge_r, badge_cx + badge_r, badge_cy + badge_r]
    
    # Border for badge
    border_w = max(1, int(s * 0.02))
    draw.ellipse(
        [badge_bbox[0] - border_w, badge_bbox[1] - border_w, badge_bbox[2] + border_w, badge_bbox[3] + border_w],
        fill=bg_color
    )
    # Emerald green badge fill
    draw.ellipse(badge_bbox, fill=(0, 200, 83, 255))

    # White Checkmark inside badge
    chk_w = max(2, int(s * 0.032))
    # Points for checkmark: start, vertex, end
    p1 = (badge_cx - int(badge_r * 0.45), badge_cy - int(badge_r * 0.05))
    p2 = (badge_cx - int(badge_r * 0.10), badge_cy + int(badge_r * 0.35))
    p3 = (badge_cx + int(badge_r * 0.45), badge_cy - int(badge_r * 0.35))
    draw.line([p1, p2], fill=(255, 255, 255, 255), width=chk_w)
    draw.line([p2, p3], fill=(255, 255, 255, 255), width=chk_w)

    return img

def main():
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    base_res = r"c:\Users\adity\Downloads\FacePay_Application\android\app\src\main\res"

    for folder, size in sizes.items():
        out_dir = os.path.join(base_res, folder)
        os.makedirs(out_dir, exist_ok=True)
        img = create_facepay_icon(size)
        out_path = os.path.join(out_dir, "ic_launcher.png")
        img.save(out_path, "PNG")
        print(f"Generated {out_path} ({size}x{size})")

    # High-resolution 512x512 Play Store Icon
    store_dir = r"c:\Users\adity\Downloads\FacePay_Application\play_store_assets"
    os.makedirs(store_dir, exist_ok=True)
    store_img = create_facepay_icon(512)
    store_path = os.path.join(store_dir, "icon_512.png")
    store_img.save(store_path, "PNG")
    print(f"Generated Play Store asset: {store_path} (512x512)")

if __name__ == '__main__':
    main()
