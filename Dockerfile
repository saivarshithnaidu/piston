# Using the official Piston API image
FROM ghcr.io/engineer-man/piston/api:latest

# 1. Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# 2. Set working directory
WORKDIR /piston

# 3. Install runtimes using the CORRECT installer path /piston/packages/install
# We install one by one and clean /tmp to avoid disk space issues on Render Free
RUN /piston/packages/install python && \
    /piston/packages/install node && \
    /piston/packages/install java && \
    /piston/packages/install cpp && \
    rm -rf /tmp/*

# 4. Copy the secure zero-dependency proxy
COPY proxy.js /piston/proxy.js

# 5. Create the startup script to sequence the engine and the proxy
RUN echo '#!/bin/sh\n\
echo "Initializing Piston Engine on 127.0.0.1:3000..."\n\
node /piston/src/index.js & \n\
\n\
echo "Waiting 10 seconds for service initialization..."\n\
sleep 10\n\
\n\
echo "Starting Neural Security Proxy on port 2000..."\n\
node /piston/proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

# 6. Expose the public proxy port
EXPOSE 2000

# 7. Start the secure execution stack
CMD ["sh", "/piston/start.sh"]
