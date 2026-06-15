# WebPortal - Home Lab App Dashboard

A simple, drag-and-drop web portal for managing links to services and applications in your home lab. Easily add, organize, and remove web links with automatic YAML-based configuration persistence.

## Features

- 🎯 **Drag-and-Drop Ordering** - Reorder links by dragging them
- ➕ **Add/Remove Links** - Quickly add new services or remove existing ones
- 📋 **Import/Export Configuration** - Save and restore your portal setup using YAML files
- 🎨 **Clean UI** - Simple, responsive web interface
- 🚀 **Easy Installation** - One-command installation script for Ubuntu Server
- 💾 **Persistent Storage** - Configuration saved in YAML format
- 🔄 **Systemd Service** - Run as background service on boot

## Prerequisites

- Ubuntu Server (18.04 or later) or any Debian-based Linux
- Internet connection (for downloading dependencies)
- Basic terminal access

## Quick Installation (Automated)

The easiest way to install WebPortal is using the automated installation script:

### Step 1: Clone the Repository

```bash
git clone https://github.com/nikkosojasun/webportal.git
cd webportal
```

### Step 2: Run the Installation Script

```bash
bash install.sh
```

The installation script will automatically:
- ✓ Check your system requirements
- ✓ Install Python 3 and pip (if needed)
- ✓ Update system packages
- ✓ Create a Python virtual environment
- ✓ Install all dependencies
- ✓ Verify the installation
- ✓ Create configuration directory

### Step 3: Start the Application

After installation, activate the virtual environment and run:

```bash
source venv/bin/activate
python3 app.py
```

The application will start on `http://localhost:5000`

### Step 4: Access the Portal

Open your web browser and navigate to:
```
http://localhost:5000
```

---

## Alternative: Manual Installation

If you prefer to install manually, follow these steps:

### Manual Step 1: Install System Dependencies

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-dev python3-pip git
```

### Manual Step 2: Clone Repository

```bash
git clone https://github.com/nikkosojasun/webportal.git
cd webportal
```

### Manual Step 3: Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
```

### Manual Step 4: Install Python Dependencies

```bash
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

### Manual Step 5: Run the Application

```bash
python3 app.py
```

---

## Run as a Background Service (Systemd)

To run WebPortal automatically on boot as a background service:

### Automated Service Installation

```bash
sudo bash install-service.sh
```

Then manage the service with:

```bash
# Start the service
sudo systemctl start webportal

# Stop the service
sudo systemctl stop webportal

# Check status
sudo systemctl status webportal

# View logs
sudo journalctl -u webportal -f

# Restart the service
sudo systemctl restart webportal
```

### Manual Service Installation

If you prefer to set up the service manually:

1. Create the service file:
```bash
sudo nano /etc/systemd/system/webportal.service
```

2. Add the following content (replace `/path/to/webportal` with your actual path):
```ini
[Unit]
Description=WebPortal Home Lab Dashboard
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/path/to/webportal
Environment="PATH=/path/to/webportal/venv/bin"
ExecStart=/path/to/webportal/venv/bin/python3 /path/to/webportal/app.py
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

4. Verify it's running:
```bash
sudo systemctl status webportal
```

---

## Usage Guide

### Creating Links

1. **Click the "+ Add Link" button** in the header
2. **Fill in the link information:**
   - **Title** *(required)* - Name of your service
     - Example: "Plex Media Server", "Home Assistant", "Nextcloud"
   - **URL** *(required)* - Full URL to access the service
     - Example: "http://192.168.1.100:32400"
   - **Description** *(optional)* - Brief description of the service
     - Example: "Media streaming service"
   - **Category** *(optional)* - Group links by category
     - Example: "Entertainment", "Smart Home", "Storage"
   - **Color** *(optional)* - Choose a color for the card
     - Click the color box to pick a color, or select a preset color
3. **Click "Save"** to add the link
4. Your link will appear as a card on the dashboard

**Example Links to Add:**
- Plex: `http://192.168.1.100:32400`
- Home Assistant: `http://192.168.1.100:8123`
- Nextcloud: `http://192.168.1.100:8081`
- Portainer: `http://192.168.1.100:9000`

### Ordering Links (Drag and Drop)

1. **Click and hold** on any link card
2. **Drag it** to your desired position
3. **Release** the mouse to drop it
4. The order is **automatically saved** to your configuration

This allows you to organize your links in any order you prefer!

### Deleting Links

1. **Hover over** the link card you want to remove
2. **Click the "Delete" button** (red button on the card)
3. **Confirm the deletion** when prompted
4. The link is immediately removed and saved

### Exporting Configuration

To backup your links or migrate to another server:

1. **Click the "⚙️ Settings" button** in the header
2. **Click "📥 Export Configuration"**
3. A YAML file will **download to your computer**
4. Save this file safely for backup or migration

**File naming:** `webportal_config_YYYYMMDD_HHMMSS.yaml`

### Importing Configuration

To restore links from a backup:

1. **Click the "⚙️ Settings" button** in the header
2. **Click "📤 Import Configuration"**
3. **Select a YAML file** from your computer
4. The application will **load all links** from the file
5. The dashboard will **refresh** with your imported links

**Important:** Importing will replace all existing links with the ones from the file.

---

## Configuration File Format

The YAML configuration file uses the following format:

```yaml
links:
  - title: "Plex Media Server"
    url: "http://192.168.1.100:32400"
    description: "Media streaming service for movies and TV shows"
    category: "Entertainment"
    color: "#FF6B6B"
    order: 0

  - title: "Home Assistant"
    url: "http://192.168.1.100:8123"
    description: "Home automation and smart home hub"
    category: "Smart Home"
    color: "#4ECDC4"
    order: 1

  - title: "Nextcloud"
    url: "http://192.168.1.100:8081"
    description: "File storage, sync and collaboration"
    category: "Storage"
    color: "#45B7D1"
    order: 2
```

### Configuration Field Descriptions

- **title** *(required)* - Display name of the link
- **url** *(required)* - Full URL to the service
- **description** *(optional)* - Description shown on the card
- **category** *(optional)* - Category tag (default: "Other")
- **color** *(optional)* - Hex color code for the card border (default: "#3498DB")
- **order** *(optional)* - Display order (0, 1, 2, etc.)

### Color Reference

Popular color presets available in the UI:

- 🔴 Red: `#FF6B6B`
- 🟦 Cyan: `#4ECDC4`
- 🔵 Blue: `#45B7D1`
- 🟡 Yellow: `#F7DC6F`
- 🟣 Purple: `#BB8FCE`
- 🔹 Light Blue: `#85C1E2`

---

## Configuration File Location

By default, WebPortal stores your configuration at:

```
~/.webportal/config.yaml
```

You can:
- **Manually edit** this file with any text editor
- **Back it up** by copying it to another location
- **Share it** between multiple installations
- **Delete it** to start fresh (the directory will be recreated on next run)

### View Your Configuration

```bash
cat ~/.webportal/config.yaml
```

### Backup Your Configuration

```bash
cp ~/.webportal/config.yaml ~/webportal_backup_$(date +%Y%m%d_%H%M%S).yaml
```

### Restore from Backup

Use the Import Configuration feature in the UI, or:

```bash
cp ~/webportal_backup_20240115_120000.yaml ~/.webportal/config.yaml
```

---

## Troubleshooting

### Port 5000 Already in Use

If port 5000 is already in use by another application:

1. **Find the port number** you want to use (e.g., 8000, 8080, 5001)
2. **Edit `app.py`:**
```bash
nano app.py
```

3. **Find the last line** and change the port:
```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)  # Change 5000 to your port
```

4. **Restart the application**

Or find which process is using port 5000:
```bash
sudo lsof -i :5000
```

### Configuration File Issues

If your configuration becomes corrupted or you want to start fresh:

```bash
# Delete the configuration file
rm ~/.webportal/config.yaml

# Restart the application
# A new fresh configuration will be created
python3 app.py
```

### Virtual Environment Issues

If you get errors related to the virtual environment:

```bash
# Deactivate current environment
deactivate

# Remove the venv directory
rm -rf venv

# Create a new virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies again
pip install -r requirements.txt
```

### Permission Denied Errors

If you get permission denied when running scripts:

```bash
# Make scripts executable
chmod +x install.sh
chmod +x install-service.sh

# Then run them
bash install.sh
```

### Accessing from Other Machines

To access WebPortal from another computer on your network:

1. **Find your server's IP address:**
```bash
hostname -I
```

2. **Access the portal using:**
```
http://192.168.x.x:5000  # Replace with your server's IP
```

If you can't access from another machine, check:
- Firewall settings (port 5000 should be open)
- Your server is on the same network
- The application is running: `sudo systemctl status webportal`

### Service Won't Start

Check the service logs for errors:

```bash
# View recent logs
sudo journalctl -u webportal -n 50

# Follow logs in real-time
sudo journalctl -u webportal -f

# Check service status
sudo systemctl status webportal
```

### Out of Memory or CPU Issues

If the application uses too many resources:

1. Check current resource usage:
```bash
ps aux | grep app.py
```

2. Restart the service to clear memory:
```bash
sudo systemctl restart webportal
```

---

## File Structure

```
webportal/
├── README.md                    # Documentation (this file)
├── requirements.txt             # Python dependencies
├── install.sh                   # Automated installation script
├── install-service.sh           # Systemd service installation script
├── app.py                       # Flask backend application
├── static/
│   ├── css/
│   │   └── style.css           # Application styles
│   └── js/
│       └── app.js              # Client-side JavaScript
├── templates/
│   └── index.html              # HTML template
├── examples/
│   └── config.example.yaml     # Example configuration
├── venv/                        # Python virtual environment (created by install.sh)
└── .gitignore                  # Git ignore rules
```

---

## Accessing Your Portal

### Local Access

```
http://localhost:5000
```

### Network Access

Find your server's IP:
```bash
hostname -I
```

Then access:
```
http://<your-server-ip>:5000
```

### Example IPs

- `http://192.168.1.100:5000`
- `http://192.168.0.50:5000`
- `http://10.0.0.25:5000`

---

## Environment Variables

You can customize the application behavior using environment variables:

```bash
# Change the port
PORT=8000 python3 app.py

# Change the host
HOST=0.0.0.0 python3 app.py

# Disable debug mode
FLASK_ENV=production python3 app.py
```

---

## Security Notes

⚠️ **Important Security Considerations:**

1. **Local Network Only** - WebPortal is designed for trusted home lab networks
2. **No Authentication** - Anyone with access can modify links
3. **Use Firewall** - Only open port 5000 to trusted devices
4. **HTTPS** - For production use, consider using a reverse proxy with HTTPS (nginx, Caddy)
5. **Backup Configuration** - Regularly export and backup your configuration

---

## Performance Tips

1. **Regular Backups** - Export your configuration monthly
2. **Clean Cache** - Clear browser cache if styles seem outdated
3. **Monitor Logs** - Check logs regularly for errors
4. **Resource Monitoring** - Monitor CPU and memory usage

---

## Updates and Upgrades

To update WebPortal to the latest version:

```bash
cd webportal
git pull origin main
source venv/bin/activate
pip install --upgrade -r requirements.txt
sudo systemctl restart webportal
```

---

## License

MIT License - Feel free to use and modify as needed

---

## Contributing

Contributions are welcome! Feel free to:
- Report issues
- Suggest features
- Submit pull requests
- Improve documentation

---

## Support

For issues, questions, or suggestions:

1. Check the **Troubleshooting** section above
2. Review **Configuration File Format** section
3. Check application **logs**: `sudo journalctl -u webportal -f`
4. Open an issue on GitHub

---

## Changelog

### Version 1.0.0 (Initial Release)
- ✓ Drag-and-drop link ordering
- ✓ Add/remove links
- ✓ Import/export YAML configuration
- ✓ Responsive web UI
- ✓ Automated installation script
- ✓ Systemd service support
- ✓ Color customization

---

Happy labbing! 🎉
