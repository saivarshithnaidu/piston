FROM ghcr.io/engineer-man/piston/api:latest

# Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# No npm install needed anymore (zero-dependency proxy)

# Installation: Use the pre-set scripts directly (most common location)
RUN sh /piston/index.sh && \
    sh /piston/install.sh python && \
    sh /piston/install.sh node && \
    sh /piston/install.sh java && \
    sh /piston/install.sh cpp

# Ensure both files are copied
COPY proxy.js /piston/proxy.js

# Optimized startup
RUN echo '#!/bin/sh\n\
node src/index.js & \n\
sleep 10 && node /piston/proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

EXPOSE 2000
CMD ["sh", "/piston/start.sh"]
