# core/tools/visual_perception.py

"""
Visual Perception Module Integration Tools
Provides utilities for camera feed processing and object detection integration.
"""

from typing import Dict, List, Optional
import cv2
import torch
from torchvision import models
from PIL import Image
import numpy as np

class VisualPerceptionEngine:
    def __init__(self, model_path: str = "yolov8s.pt"):
        """Initialize with YOLOv8 model for object detection"""
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = self._load_model(model_path)
        self.model.to(self.device)
        
    def _load_model(self, path: str) -> torch.nn.Module:
        """Load PyTorch model with version pinning"""
        # Example: Use specific version of YOLOv8
        model = models.get_model("yolov8s", pretrained=True)
        model.load_state_dict(torch.load(path, map_location=self.device))
        model.eval()
        return model
    
    def process_frame(self, frame: np.ndarray) -> Dict[str, List[Dict]]:
        """
        Process single frame from camera feed
        Returns: Dictionary of detected objects with bounding boxes
        """
        # Convert to PIL Image
        image = Image.fromarray(frame)
        
        # Preprocess
        transform = self._get_transform()
        img_tensor = transform(image).unsqueeze(0).to(self.device)
        
        # Inference
        with torch.no_grad():
            outputs = self.model(img_tensor)
        
        # Postprocess
        results = self._postprocess(outputs, image.size)
        return results
    
    def _get_transform(self):
        """Get preprocessing transform for model input"""
        return transforms.Compose([
            transforms.Resize((640, 640)),
            transforms.ToTensor(),
        ])
    
    def _postprocess(self, outputs, original_size):
        """Convert model outputs to human-readable format"""
        # Example postprocessing logic
        boxes = outputs["boxes"].cpu().numpy()
        labels = outputs["labels"].cpu().numpy()
        scores = outputs["scores"].cpu().numpy()
        
        # Convert to dictionary format
        objects = []
        for box, label, score in zip(boxes, labels, scores):
            if score > 0.5:  # Confidence threshold
                objects.append({
                    "label": label,
                    "score": float(score),
                    "bounding_box": {
                        "x1": float(box[0]),
                        "y1": float(box[1]),
                        "x2": float(box[2]),
                        "y2": float(box[3])
                    }
                })
        
        return {
            "detections": objects,
            "original_size": original_size
        }

# Example usage
if __name__ == "__main__":
    engine = VisualPerceptionEngine()
    cap = cv2.VideoCapture("rtsp://example.com/camera")
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
            
        results = engine.process_frame(frame)
        print(f"Detected objects: {results['detections']}")
        
        # Draw bounding boxes on frame (example)
        for obj in results["detections"]:
            box = obj["bounding_box"]
            cv2.rectangle(frame, 
                        (int(box["x1"]), int(box["y1"])),
                        (int(box["x2"]), int(box["y2"])),
                        (0, 255, 0), 2)
            
        cv2.imshow("Visual Perception", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()