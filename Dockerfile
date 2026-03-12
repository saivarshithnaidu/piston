# Using the official Piston API image
FROM ghcr.io/engineer-man/piston/api:latest

# Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# Install proxy dependencies
RUN npm install http-proxy

# Fail-safe installation: Try every known Piston path and method
RUN (sh /piston/index.sh && sh /piston/install.sh python node java cpp) || \
    (sh /piston/packages/index.sh && sh /piston/packages/install.sh python node java cpp) || \
    (piston install python node java cpp) || \
    (echo "Falling back to recursive search" && \
     IDX=$(find /piston -name index.sh | head -n 1) && \
     INS=$(find /piston -name install.sh | head -n 1) && \
     sh $IDX && sh $INS python node java cpp)

# Copy the security proxy
COPY proxy.js /piston/proxy.js

# Create a startup script using standard sh for maximum compatibility
RUN echo '#!/bin/sh\n\
node src/index.js & \n\
sleep 15 && node proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

EXPOSE 2000
CMD ["sh", "/piston/start.sh"]
