FROM ghcr.io/engineer-man/piston/api:latest

# 1. Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# 2. Set working directory
WORKDIR /piston

# 3. Copy the secure proxy
COPY proxy.js /piston/proxy.js

# 4. Improved startup script that finds the engine automatically
RUN echo '#!/bin/sh\n\
echo "Searching for Piston Engine..."\n\
PISTON_PATH=$(find /piston -name index.js | grep "src/index.js" | head -n 1)\n\
if [ -z "$PISTON_PATH" ]; then\n\
  echo "Error: Could not find Piston index.js. Listing /piston for debug:"\n\
  ls -R /piston\n\
  exit 1\n\
fi\n\
\n\
ENGINE_DIR=$(dirname $(dirname $PISTON_PATH))\n\
echo "Starting Piston Engine in $ENGINE_DIR..."\n\
cd $ENGINE_DIR && node src/index.js & \n\
\n\
echo "Waiting 10 seconds for neural synchronization..."\n\
sleep 10\n\
\n\
echo "Activating Security Proxy on port $PORT..."\n\
node /piston/proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

EXPOSE 2000
CMD ["sh", "/piston/start.sh"]
