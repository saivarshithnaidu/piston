FROM ghcr.io/engineer-man/piston/api:latest

# 1. Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# 2. Set working directory (Proxy Home)
WORKDIR /piston-sec

# 3. Copy the secure proxy
COPY proxy.js /piston-sec/proxy.js

# 4. Neural Autodiscovery Startup Script
# This script searches the entire container to find the Piston index.js
RUN echo '#!/bin/sh\n\
echo "Initiating Neural Autodiscovery for Piston Engine..."\n\
# Search everywhere for the entry point, excluding node_modules for speed\n\
PISTON_PATH=$(find / -name index.js 2>/dev/null | grep -v "node_modules" | grep "index.js" | head -n 1)\n\
\n\
if [ -z "$PISTON_PATH" ]; then\n\
  echo "CRITICAL: Piston entry point not found. Diagnostics:"\n\
  echo "Current Context: $(pwd)"\n\
  echo "Listing Root: $(ls -F /)"\n\
  exit 1\n\
fi\n\
\n\
ENGINE_DIR=$(dirname $(dirname $PISTON_PATH))\n\
echo "Target Identified: $PISTON_PATH"\n\
echo "Starting Piston Engine in $ENGINE_DIR..."\n\
\n\
# Start the engine in its native directory\n\
(cd $ENGINE_DIR && node src/index.js) & \n\
\n\
echo "Establishing Neural Sync (12 seconds)..."\n\
sleep 12\n\
\n\
echo "Activating Neural Security Shield on port $PORT..."\n\
node /piston-sec/proxy.js\n\
' > /piston-sec/start.sh && chmod +x /piston-sec/start.sh

EXPOSE 2000
CMD ["sh", "/piston-sec/start.sh"]
