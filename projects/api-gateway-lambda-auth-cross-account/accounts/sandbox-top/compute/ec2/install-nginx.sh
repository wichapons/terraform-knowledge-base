#!/bin/bash -e

CONF_DEST="/etc/nginx/conf.d/topazio.conf"
TMP_CONF="/tmp/topazio.conf.$$"

echo "==> Installing nginx (if missing)"
if ! command -v nginx >/dev/null 2>&1; then
  sudo yum install -y nginx
else
  echo "nginx already installed"
fi

echo "==> Writing nginx config to $CONF_DEST"
cat > "$TMP_CONF" <<'NGINX'
server {
    listen 80;
    server_name _;

    # Root returns a simple text for ALB / external checks
    location = / {
        add_header Content-Type text/plain;
        return 200 'hello topazio';
    }

    # ALB health check endpoint
    location = /health {
        access_log off;
        add_header Content-Type text/plain;
        return 200 'ok';
    }

    # Tune body size and timeouts for uploads proxied later (if needed)
    client_max_body_size 100m;
    proxy_read_timeout 90s;
    proxy_connect_timeout 30s;
    proxy_send_timeout 90s;

    # Optional: if you later proxy to a local app, you can use a block like this:
    # location /api/ {
    #   proxy_pass http://127.0.0.1:3000;
    #   proxy_set_header Host $host;
    #   proxy_set_header X-Real-IP $remote_addr;
    #   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #   proxy_set_header X-Forwarded-Proto $scheme;
    # }

    # Optional static location (adjust path if your app uses uploads)
    # location /uploads/ {
    #     alias /home/ec2-user/topazio-shop-backend-aws/uploads/;
    #     autoindex off;
    # }
}
NGINX

# Move into place only if changed to avoid unnecessary reloads
if ! sudo cmp -s "$TMP_CONF" "$CONF_DEST" 2>/dev/null; then
  sudo mv "$TMP_CONF" "$CONF_DEST"
  echo "Deployed $CONF_DEST"
else
  echo "No changes to $CONF_DEST"
  rm -f "$TMP_CONF"
fi

echo "==> Testing nginx config"
sudo nginx -t

echo "==> Enabling and starting nginx"
sudo systemctl enable --now nginx

# Wait a moment and check responses
sleep 1
ROOT_RESPONSE=$(curl -sS --max-time 2 http://127.0.0.1/ || echo "__ERR__")
HEALTH_RESPONSE=$(curl -sS --max-time 2 http://127.0.0.1/health || echo "__ERR__")

echo "==> Quick verification:"
echo "  /      -> '${ROOT_RESPONSE}'"
echo "  /health -> '${HEALTH_RESPONSE}'"

if [ "$ROOT_RESPONSE" = "hello topazio" ] && [ "$HEALTH_RESPONSE" = "ok" ]; then
  echo "SUCCESS: Nginx serving expected responses."
  exit 0
else
  echo "ERROR: Unexpected responses from nginx. See journal for details:" >&2
  sudo journalctl -u nginx -n 200 --no-pager
  exit 2
fi
