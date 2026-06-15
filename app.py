#!/usr/bin/env python3
"""
WebPortal - Home Lab App Dashboard
A simple Flask application for managing links to services and applications.
"""

import os
import yaml
from pathlib import Path
from flask import Flask, render_template, request, jsonify, send_file
from datetime import datetime
import io

app = Flask(__name__)

# Configuration
CONFIG_DIR = Path.home() / '.webportal'
CONFIG_FILE = CONFIG_DIR / 'config.yaml'

# Ensure config directory exists
CONFIG_DIR.mkdir(exist_ok=True)


def load_config():
    """Load configuration from YAML file."""
    if CONFIG_FILE.exists():
        try:
            with open(CONFIG_FILE, 'r') as f:
                config = yaml.safe_load(f)
                return config if config else {'links': []}
        except Exception as e:
            print(f"Error loading config: {e}")
            return {'links': []}
    return {'links': []}


def save_config(config):
    """Save configuration to YAML file."""
    try:
        with open(CONFIG_FILE, 'w') as f:
            yaml.dump(config, f, default_flow_style=False, sort_keys=False)
        return True
    except Exception as e:
        print(f"Error saving config: {e}")
        return False


def sort_links(links):
    """Sort links by order field."""
    return sorted(links, key=lambda x: x.get('order', 0))


@app.route('/')
def index():
    """Render the main portal page."""
    config = load_config()
    links = sort_links(config.get('links', []))
    return render_template('index.html', links=links)


@app.route('/api/links', methods=['GET'])
def get_links():
    """Get all links as JSON."""
    config = load_config()
    links = sort_links(config.get('links', []))
    return jsonify(links)


@app.route('/api/links', methods=['POST'])
def add_link():
    """Add a new link."""
    data = request.get_json()
    config = load_config()
    
    # Validate required fields
    if not data.get('title') or not data.get('url'):
        return jsonify({'error': 'Title and URL are required'}), 400
    
    # Create new link
    new_link = {
        'title': data.get('title'),
        'url': data.get('url'),
        'description': data.get('description', ''),
        'category': data.get('category', 'Other'),
        'color': data.get('color', '#3498DB'),
        'order': len(config.get('links', []))
    }
    
    config['links'].append(new_link)
    save_config(config)
    
    return jsonify(new_link), 201


@app.route('/api/links/<int:index>', methods=['DELETE'])
def delete_link(index):
    """Delete a link by index."""
    config = load_config()
    links = config.get('links', [])
    
    if 0 <= index < len(links):
        links.pop(index)
        # Reorder remaining links
        for i, link in enumerate(links):
            link['order'] = i
        config['links'] = links
        save_config(config)
        return jsonify({'success': True}), 200
    
    return jsonify({'error': 'Link not found'}), 404


@app.route('/api/links/reorder', methods=['POST'])
def reorder_links():
    """Update the order of links."""
    data = request.get_json()
    config = load_config()
    
    if 'links' in data:
        for i, link in enumerate(data['links']):
            link['order'] = i
        config['links'] = data['links']
        save_config(config)
        return jsonify({'success': True}), 200
    
    return jsonify({'error': 'Invalid data'}), 400


@app.route('/api/config/export', methods=['GET'])
def export_config():
    """Export configuration as YAML file."""
    config = load_config()
    
    # Convert to YAML string
    yaml_content = yaml.dump(config, default_flow_style=False, sort_keys=False)
    
    # Create file-like object
    bytes_obj = io.BytesIO(yaml_content.encode('utf-8'))
    
    # Return as downloadable file
    return send_file(
        bytes_obj,
        mimetype='application/x-yaml',
        as_attachment=True,
        download_name=f'webportal_config_{datetime.now().strftime("%Y%m%d_%H%M%S")}.yaml'
    )


@app.route('/api/config/import', methods=['POST'])
def import_config():
    """Import configuration from uploaded YAML file."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    try:
        # Read and parse YAML
        content = file.read().decode('utf-8')
        config = yaml.safe_load(content)
        
        # Validate configuration structure
        if not isinstance(config, dict) or 'links' not in config:
            return jsonify({'error': 'Invalid configuration format'}), 400
        
        if not isinstance(config['links'], list):
            return jsonify({'error': 'Links must be a list'}), 400
        
        # Ensure all links have required fields and are sorted
        for i, link in enumerate(config['links']):
            link['order'] = i
            if 'title' not in link or 'url' not in link:
                return jsonify({'error': 'All links must have title and url'}), 400
        
        # Save the imported configuration
        save_config(config)
        return jsonify({'success': True, 'links_count': len(config['links'])}), 200
    
    except yaml.YAMLError as e:
        return jsonify({'error': f'Invalid YAML format: {str(e)}'}), 400
    except Exception as e:
        return jsonify({'error': f'Import error: {str(e)}'}), 400


@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({'status': 'healthy'}), 200


if __name__ == '__main__':
    print("WebPortal starting...")
    print(f"Configuration file: {CONFIG_FILE}")
    app.run(host='0.0.0.0', port=5000, debug=False)
