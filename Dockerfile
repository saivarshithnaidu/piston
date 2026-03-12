FROM ghcr.io/engineer-man/piston/api:latest

# 1. Essential Config
ENV PORT=2000
# Force Piston to listen on 3000 (Internal)
ENV PISTON_BIND_ADDR=127.0.0.1:3000
ENV PISTON_DATA_DIRECTORY=/piston/data
ENV PISTON_LOG_DIRECTORY=/piston/logs
ENV PISTON_PACKAGES_DIRECTORY=/piston/packages

# 2. Setup internal directory structure
RUN mkdir -p /piston/data /piston/logs /piston/packages /piston-sec

# 3. Copy the secure proxy
COPY proxy.js /piston-sec/proxy.js

# 4. robust Startup Script
RUN echo '#!/bin/sh\n\
echo "[Neural-Bridge] Initializing Piston Core..."\n\
\n\
# Find the actual Piston API directory\n\
# We look for the package.json that belongs to the API\n\
export PISTON_API_ROOT=$(find / -name package.json 2>/dev/null | xargs grep -l "piston-api" | head -n 1 | xargs dirname)\n\
\n\
if [ -z "$PISTON_API_ROOT" ]; then\n\
  echo "[Error] Could not locate Piston API root. Falling back to /piston/api..."\n\
  PISTON_API_ROOT="/piston/api"\n\
fi\n\
\n\
echo "[Neural-Bridge] Engine Root: $PISTON_API_ROOT"\n\
cd "$PISTON_API_ROOT"\n\
\n\
# Start Piston in background\n\
# Default entry point is usually src/index.js\n\
echo "[Neural-Bridge] Launching Engine..."\n\
node src/index.js & \n\
\n\
# Wait for Piston to bind to 3000\n\
echo "[Neural-Bridge] Warming up neural clusters (12s)..."\n\
sleep 12\n\
\n\
# List what is listening just in case (if netstat/ss is available)\n\
if command -v netstat >/dev/null; then\n\
  netstat -tlpn\n\
fi\n\
\n\
echo "[Neural-Bridge] Starting Security Proxy on $PORT..."\n\
node /piston-sec/proxy.js\n\
' > /piston-sec/start.sh && chmod +x /piston-sec/start.sh

EXPOSE 2000
CMD ["sh", "/piston-sec/start.sh"]
