$nginxPath = "nginx/nginx.conf"

$config = @"
events {}

http {

    upstream application {
        server host.docker.internal:3002;
    }

    server {

        listen 80;

        location / {

            proxy_pass http://application;

            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
    }
}
"@

Set-Content -Path $nginxPath -Value $config

docker build -t devops-nginx:latest ./nginx

docker rm -f devops-nginx 2>$null

docker run -d `
    --name devops-nginx `
    -p 8080:80 `
    devops-nginx:latest

Write-Host "Traffic switched to GREEN"