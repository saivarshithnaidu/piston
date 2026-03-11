# Stage 1: Build/Install Packages
FROM ghcr.io/engineer-man/piston/piston:latest AS builder

# Install the language runtimes using the Piston CLI
RUN piston install python=3.10.0 && \
    piston install node=18.15.0 && \
    piston install java=17.0.2 && \
    piston install cpp=10.2.0

# Stage 2: Final API Image
FROM ghcr.io/engineer-man/piston/api:latest

# Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# Install proxy dependencies
RUN npm install http-proxy

# Copy the pre-installed packages from the builder stage
COPY --from=builder /piston/packages /piston/packages

# Copy the security proxy
COPY proxy.js /piston/proxy.js

# Create a startup script
RUN echo '#!/bin/bash\n\
node src/index.js & \n\
sleep 5 && node proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

EXPOSE 2000
CMD ["/piston/start.sh"]
