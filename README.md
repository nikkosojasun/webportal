# WebPortal - Home Lab App Dashboard

A simple, drag-and-drop web portal for managing links to services and applications in your home lab. Easily add, organize, and remove web links with automatic YAML-based configuration persistence.

## Features

- 🎯 **Drag-and-Drop Ordering** - Reorder links by dragging them
- ➕ **Add/Remove Links** - Quickly add new services or remove existing ones
- 📋 **Import/Export Configuration** - Save and restore your portal setup using YAML files
- 🎨 **Clean UI** - Simple, responsive web interface
- 🚀 **Easy Installation** - Works on Ubuntu Server with minimal setup
- 💾 **Persistent Storage** - Configuration saved in YAML format

## Prerequisites

- Ubuntu Server (18.04 or later)
- Python 3.8 or higher
- pip (Python package manager)

## Installation Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/nikkosojasun/webportal.git
cd webportal
```

### Step 2: Install Dependencies

```bash
pip install -r requirements.txt
```

If you don't have pip installed:
```bash
sudo apt update
sudo apt install python3-pip
```

### Step 3: Run the Application

```bash
python3 app.py
```

The application will start on `http://localhost:5000`

### Step 4: Access the Portal

Open your web browser and navigate to:
```
http://localhost:5000
```

### Optional: Run as a Service (systemd)

For persistent background operation:

1. Create a systemd service file:
```bash
sudo nano /etc/systemd/system/webportal.service
```

2. Add the following content (adjust paths as needed):
```ini
[Unit]
Description=WebPortal Home Lab Dashboard
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/path/to/webportal
ExecStart=/usr/bin/python3 /path/to/webportal/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

3. Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable webportal
sudo systemctl start webportal
```

4. Check status:
```bash
sudo systemctl status webportal
```

## Usage Guide

### Creating Links

1. Click the **"+ Add Link"** button
2. Fill in the following information:
   - **Title**: Name of your service (e.g., "Plex Media Server")
   - **URL**: The full URL (e.g., "http://192.168.1.100:32400")
   - **Description**: (Optional) Brief description of the service
   - **Category**: (Optional) Group links by category
   - **Icon/Color**: Choose a color for visual identification
3. Click **"Save"** to add the link

### Ordering Links

1. Click and hold on any link card
2. Drag it to the desired position
3. Release to drop it in place
4. The order is automatically saved

### Deleting Links

1. Hover over the link you want to remove
2. Click the **"Delete"** button (trash icon) on the card
3. Confirm the deletion when prompted
4. The link is removed and configuration is updated

### Import Configuration

To import a previously saved configuration:

1. Click **"Settings"** in the top menu
2. Click **"Import Configuration"**
3. Select a YAML file from your computer
4. The application will load all saved links
5. The page will refresh with the imported configuration

### Export Configuration

To backup your current setup:

1. Click **"Settings"** in the top menu
2. Click **"Export Configuration"**
3. A YAML file will be downloaded to your computer
4. Save it somewhere safe for backup or migration

### Configuration File Format

The YAML configuration file follows this format:

```yaml
links:
  - title: "Plex Media Server"
    url: "http://192.168.1.100:32400"
    description: "Media streaming service"
    category: "Entertainment"
    color: "#FF6B6B"
    order: 0
  
  - title: "Home Assistant"
    url: "http://192.168.1.100:8123"
    description: "Home automation hub"
    category: "Smart Home"
    color: "#4ECDC4"
    order: 1

  - title: "Nextcloud"
    url: "http://192.168.1.100:8081"
    description: "File storage and sync"
    category: "Storage"
    color: "#45B7D1"
    order: 2
```

## Configuration File Location

By default, the application stores its configuration at:
```
~/.webportal/config.yaml
```

You can also manually edit this file or use the import/export features from the UI.

## Troubleshooting

### Port 5000 Already in Use

If port 5000 is already in use, you can change it in `app.py`:

```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)  # Change 5000 to 8000 or another port
```

### Configuration File Issues

If your configuration becomes corrupted:

1. Delete the config file: `rm ~/.webportal/config.yaml`
2. Restart the application
3. A fresh configuration will be created

### Accessing from Other Machines

Make sure the server is accessible by using the server's IP address:
```
http://192.168.x.x:5000  # Replace with your server's IP
```

## File Structure

```
webportal/
├── README.md              # This file
├── requirements.txt       # Python dependencies
├── app.py                 # Flask application
├── static/
│   ├── css/
│   │   └── style.css      # Application styles
│   └── js/
│       └── app.js         # Client-side JavaScript
├── templates/
│   └── index.html         # HTML template
└── examples/
    └── config.example.yaml # Example configuration
```

## License

MIT License - Feel free to use and modify as needed

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.
