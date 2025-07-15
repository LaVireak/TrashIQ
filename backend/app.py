from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
import base64
import io
from PIL import Image
import os
import sys

app = Flask(__name__)
CORS(app)

# Initialize model variable
model = None

def load_model():
    """Load the YOLO model with error handling"""
    global model
    try:
        # Try different possible paths for the model
        possible_paths = [
            os.path.join('..', 'ai', 'models', 'best.pt'),
            os.path.join('ai', 'models', 'best.pt'),
            'best.pt',
            os.path.join('models', 'best.pt')
        ]
        
        model_path = None
        for path in possible_paths:
            if os.path.exists(path):
                model_path = path
                break
        
        if model_path is None:
            print("❌ Model file 'best.pt' not found in any of these locations:")
            for path in possible_paths:
                print(f"   - {os.path.abspath(path)}")
            return False
        
        print(f"📦 Loading model from: {os.path.abspath(model_path)}")
        
        # Import YOLO here to catch import errors
        from ultralytics import YOLO
        model = YOLO(model_path)
        
        print("✅ Model loaded successfully!")
        print(f"📊 Model classes: {list(model.names.values())}")
        return True
        
    except ImportError as e:
        print(f"❌ Failed to import ultralytics: {e}")
        print("💡 Try installing: pip install ultralytics")
        return False
    except Exception as e:
        print(f"❌ Failed to load model: {e}")
        return False

# Load model on startup
model_loaded = load_model()

# Define trash categories based on your dataset classes
TRASH_CATEGORIES = {
    'can': {
        'name': 'Aluminum Can',
        'type': 'Recyclable',
        'material': 'Aluminum',
        'points': 15,
        'color': 'green',
        'disposal_method': 'Recycling Bin',
        'description': 'Aluminum cans are highly recyclable and valuable'
    },
    'cardboard': {
        'name': 'Cardboard',
        'type': 'Recyclable',
        'material': 'Paper',
        'points': 8,
        'color': 'brown',
        'disposal_method': 'Recycling Bin',
        'description': 'Cardboard should be clean and dry for recycling'
    },
    'glass bottle': {
        'name': 'Glass Bottle',
        'type': 'Recyclable',
        'material': 'Glass',
        'points': 12,
        'color': 'green',
        'disposal_method': 'Glass Recycling',
        'description': 'Glass bottles can be recycled indefinitely'
    },
    'glass mug': {
        'name': 'Glass Mug',
        'type': 'Recyclable',
        'material': 'Glass',
        'points': 10,
        'color': 'green',
        'disposal_method': 'Glass Recycling',
        'description': 'Glass mugs can be recycled with other glassware'
    },
    'paper': {
        'name': 'Paper',
        'type': 'Recyclable',
        'material': 'Paper',
        'points': 5,
        'color': 'blue',
        'disposal_method': 'Paper Recycling',
        'description': 'Clean paper is easily recyclable'
    },
    'plastic bottle': {
        'name': 'Plastic Bottle',
        'type': 'Recyclable',
        'material': 'Plastic',
        'points': 10,
        'color': 'blue',
        'disposal_method': 'Plastic Recycling',
        'description': 'Remove caps and labels before recycling'
    },
    'solid mug': {
        'name': 'Ceramic Mug',
        'type': 'Non-recyclable',
        'material': 'Ceramic',
        'points': 3,
        'color': 'orange',
        'disposal_method': 'General Waste',
        'description': 'Ceramic items cannot be recycled in standard programs'
    },
    'water bottle': {
        'name': 'Water Bottle',
        'type': 'Recyclable',
        'material': 'Plastic',
        'points': 10,
        'color': 'blue',
        'disposal_method': 'Plastic Recycling',
        'description': 'Plastic water bottles are highly recyclable'
    }
}

@app.route('/', methods=['GET'])
def home():
    """Home route to show server status"""
    return jsonify({
        'message': 'TrashIQ Detection Server is running!',
        'status': 'healthy',
        'model_loaded': model_loaded,
        'available_endpoints': {
            'health': '/health',
            'detect': '/detect (POST)',
            'classes': '/classes'
        },
        'model_classes': list(model.names.values()) if model else [],
        'total_classes': len(model.names) if model else 0
    })

@app.route('/detect', methods=['POST'])
def detect_trash():
    if not model_loaded or model is None:
        return jsonify({
            'success': False,
            'error': 'Model not loaded. Please check server logs.'
        }), 500
    
    try:
        # Get the image from request
        data = request.get_json()
        if not data or 'image' not in data:
            return jsonify({
                'success': False,
                'error': 'No image data provided'
            }), 400
        
        image_data = data['image']
        
        # Decode base64 image
        image_data = image_data.split(',')[1] if ',' in image_data else image_data
        image_bytes = base64.b64decode(image_data)
        image = Image.open(io.BytesIO(image_bytes))
        
        # Convert to OpenCV format
        opencv_image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
        
        # Run inference
        results = model(opencv_image)
        
        detections = []
        for result in results:
            boxes = result.boxes
            if boxes is not None:
                for box in boxes:
                    # Get class name
                    class_id = int(box.cls[0])
                    class_name = model.names[class_id]
                    confidence = float(box.conf[0])
                    
                    # Only include high confidence detections
                    if confidence > 0.3:  # Lowered threshold for better detection
                        # Get category info
                        category_info = TRASH_CATEGORIES.get(class_name, {
                            'name': class_name.replace('_', ' ').title(),
                            'type': 'Unknown',
                            'material': 'Unknown',
                            'points': 1,
                            'color': 'gray',
                            'disposal_method': 'Check Local Guidelines',
                            'description': 'Unknown item type'
                        })
                        
                        # Get bounding box coordinates
                        bbox = box.xyxy[0].tolist()  # [x1, y1, x2, y2]
                        
                        detection = {
                            'class_name': class_name,
                            'confidence': round(confidence, 3),
                            'name': category_info['name'],
                            'type': category_info['type'],
                            'material': category_info['material'],
                            'points': category_info['points'],
                            'color': category_info['color'],
                            'disposal_method': category_info['disposal_method'],
                            'description': category_info['description'],
                            'bbox': {
                                'x1': round(bbox[0], 2),
                                'y1': round(bbox[1], 2),
                                'x2': round(bbox[2], 2),
                                'y2': round(bbox[3], 2),
                                'width': round(bbox[2] - bbox[0], 2),
                                'height': round(bbox[3] - bbox[1], 2)
                            }
                        }
                        detections.append(detection)
        
        # Sort by confidence and return results
        detections.sort(key=lambda x: x['confidence'], reverse=True)
        
        if detections:
            best_detection = detections[0]
            return jsonify({
                'success': True,
                'detection': best_detection,
                'all_detections': detections,
                'total_detections': len(detections),
                'model_classes': list(TRASH_CATEGORIES.keys())
            })
        else:
            return jsonify({
                'success': False,
                'message': 'No trash items detected with sufficient confidence',
                'model_classes': list(TRASH_CATEGORIES.keys())
            })
            
    except Exception as e:
        print(f"Error in detection: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/classes', methods=['GET'])
def get_classes():
    """Get all available detection classes"""
    return jsonify({
        'classes': list(TRASH_CATEGORIES.keys()),
        'categories': TRASH_CATEGORIES
    })

@app.route('/health', methods=['GET'])
def health_check():
    try:
        model_classes = list(model.names.values()) if model else []
        return jsonify({
            'status': 'healthy' if model_loaded else 'model_not_loaded',
            'model_loaded': model_loaded,
            'model_classes': model_classes,
            'total_classes': len(model_classes)
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500

if __name__ == '__main__':
    print("🚀 Starting TrashIQ Detection Server...")
    if model_loaded:
        print(f"✅ Model loaded successfully")
        print(f"📊 Available classes: {list(TRASH_CATEGORIES.keys())}")
    else:
        print("❌ Model not loaded - check the logs above")
    
    print("🌐 Server starting on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)