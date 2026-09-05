# Get project root
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Nginx configuration path
$nginxPath = Join-Path $projectRoot "nginx\nginx.conf"

Write-Host "[+] Project root: $projectRoot"
Write-Host "[+] Nginx config: $nginxPath"

# Make sure nginx directory exists
$nginxDirectory = Split-Path $nginxPath -Parent

if (!(Test-Path $nginxDirectory)) {
    Write-Host "[ERROR] Nginx directory does not exist:"
    Write-Host $nginxDirectory
    exit 1
}

# Blue configuration
$config = @"
events {}

http {

    upstream backend {
        server host.docker.internal:3001;
    }

    server {

        listen 80;

        location / {

            proxy_pass http://backend;

            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
    }
}
"@

# Write nginx configuration
Set-Content -Path $nginxPath -Value $config

Write-Host "[+] Nginx configuration updated for BLUE"

# Stop old nginx container if it exists
docker rm -f devops-nginx 2>$null

# Build nginx image from PROJECT ROOT
docker build -t devops-nginx:latest "$projectRoot\nginx"

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Nginx image build failed."
    exit 1
}

# Run nginx
docker run -d `
    --name devops-nginx `
    -p 8080:80 `
    devops-nginx:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Nginx container failed to start."
    exit 1
}

Write-Host ""
Write-Host "[SUCCESS] Traffic switched to BLUE"
Write-Host "[+] Production URL: http://localhost:8080"