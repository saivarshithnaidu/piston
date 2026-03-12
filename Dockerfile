# Using the official Piston API image
FROM ghcr.io/engineer-man/piston/api:latest

# Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# Install proxy dependencies
RUN npm install http-proxy

# Robust installation: Find the scripts wherever they are and run them
RUN FILE_INDEX=$(find /piston -name index.sh | head -n 1) && \
    FILE_INSTALL=$(find /piston -name install.sh | head -n 1) && \
    if [ -z "$FILE_INDEX" ]; then echo "Fallback to CLI installation"; \
    piston -V && piston install python node java cpp; \
    else \
    cd $(dirname $FILE_INDEX) && \
    ./index.sh && \
    ./install.sh python && \
    ./install.sh node && \
    ./install.sh java && \
    ./install.sh cpp; \
    fi

# Copy the security proxy
COPY proxy.js /piston/proxy.js

# Create a startup script (Ensure Piston is ready before Proxy)
RUN echo '#!/bin/bash\n\
node src/index.js & \n\
sleep 10 && node proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

EXPOSE 2000
CMD ["/piston/start.sh"]
