# Using the official Piston API image (This pull worked before)
FROM ghcr.io/engineer-man/piston/api:latest

# Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# Install proxy dependencies
RUN npm install http-proxy

# Install the language runtimes
# We search for the install scripts to ensure we find the correct path
RUN cd /piston && \
    (./index.sh || ./packages/index.sh || sh index.sh) && \
    (./install.sh python || ./packages/install.sh python || sh install.sh python) && \
    (./install.sh node || ./packages/install.sh node || sh install.sh node) && \
    (./install.sh java || ./packages/install.sh java || sh install.sh java) && \
    (./install.sh cpp || ./packages/install.sh cpp || sh install.sh cpp)

# Copy the security proxy
COPY proxy.js /piston/proxy.js

# Create a startup script
RUN echo '#!/bin/bash\n\
node src/index.js & \n\
sleep 5 && node proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

EXPOSE 2000
CMD ["/piston/start.sh"]
