#!/bin/bash
# Azure VM Custom Script Extension — Nginx setup
set -e

echo "=== Updating package index ==="
apt-get update -y

echo "=== Installing Nginx ==="
apt-get install -y nginx

echo "=== Enabling Nginx to start on boot ==="
systemctl enable nginx
systemctl start nginx

echo "=== Deploying website ==="
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Azure VM | Nginx</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; margin-top: 100px; background: #f0f4ff; }
    h1 { color: #0078d4; }
    p { color: #555; }
  </style>
</head>
<body>
  <h1>Hello from Azure VM!</h1>
  <p>Hosted on Azure Virtual Machine with Nginx</p>
  <p>Region: East US | OS: Ubuntu 22.04 LTS</p>
</body>
</html>
EOF

echo "=== Nginx installation complete ==="
systemctl status nginx
