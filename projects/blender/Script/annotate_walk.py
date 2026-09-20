import cv2
import numpy as np
import os

image_path = r"D:\Atlas\projects\blender\Reference\axion walk.png"
output_path = r"D:\Atlas\projects\blender\Scripts\axion walk.png"

if not os.path.exists(r"D:\Atlas\projects\blender\Scripts"):
    os.makedirs(r"D:\Atlas\projects\blender\Scripts")

image = cv2.imread(image_path)
if image is None:
    print("Could not read image.")
    exit(1)

h, w, c = image.shape
num_poses = 8
slice_w = w // num_poses

# Prepare colors
COLOR_DEFORM = (255, 0, 0)   # Blue for deform bones
COLOR_IK = (0, 0, 255)       # Red for IK controls
COLOR_TEXT = (0, 0, 0)       # Black for text

labels = [
    "CONTACT L", "DOWN L", "PASSING L", "UP L",
    "CONTACT R", "DOWN R", "PASSING R", "UP R"
]

def draw_point_label(img, x, y, label, is_ik=False):
    color = COLOR_IK if is_ik else COLOR_DEFORM
    cv2.circle(img, (x, y), 4, color, -1)
    # Background for text
    (text_w, text_h), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.4, 1)
    cv2.rectangle(img, (x+8, y-text_h-4), (x+8+text_w, y+4), (255,255,255), -1)
    cv2.putText(img, label, (x+8, y), cv2.FONT_HERSHEY_SIMPLEX, 0.4, color, 1)

final_image = image.copy()

# Draw legend
cv2.rectangle(final_image, (10, 10), (350, 70), (255, 255, 255), -1)
cv2.putText(final_image, "BLUE: Deform Bones (spine, thigh, shin, foot, etc)", (20, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.5, COLOR_DEFORM, 1)
cv2.putText(final_image, "RED: IK Controls (foot_ik, knee_pole, hand_ik, etc)", (20, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.5, COLOR_IK, 1)

# Annotate each slice roughly
for i in range(num_poses):
    offset_x = i * slice_w
    cx = offset_x + slice_w // 2
    
    # Very approximate Y coordinates for humanoid in the image
    y_head = int(h * 0.15)
    y_spine = int(h * 0.35)
    y_hand = int(h * 0.45)
    y_thigh = int(h * 0.5)
    y_knee = int(h * 0.65)
    y_shin = int(h * 0.75)
    y_foot = int(h * 0.85)
    
    # We alternate L and R labels based on pose (L-poses focus on left leg, R-poses focus on right leg)
    is_left_pose = i < 4
    
    leg_str = ".L" if is_left_pose else ".R"
    other_leg_str = ".R" if is_left_pose else ".L"
    
    # Draw central bones
    draw_point_label(final_image, cx, y_head, "head/neck")
    draw_point_label(final_image, cx, y_spine, "spine (pelvis)")
    draw_point_label(final_image, cx, h - int(h*0.05), "root", True)
    
    # Draw primary action leg (front/main)
    lx = cx + 20
    draw_point_label(final_image, lx, y_thigh, f"thigh{leg_str}")
    draw_point_label(final_image, lx + 20, y_knee, f"knee_pole{leg_str}", True)
    draw_point_label(final_image, lx, y_shin, f"shin{leg_str}")
    draw_point_label(final_image, lx, y_foot, f"foot{leg_str} / foot_ik{leg_str}", True)
    
    # Draw hand
    hx = cx - 30
    draw_point_label(final_image, hx, y_hand, f"hand{leg_str} / hand_ik{leg_str}", True)

cv2.imwrite(output_path, final_image)
print(f"Saved annotated image to {output_path}")
