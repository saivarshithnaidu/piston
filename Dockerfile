# Using the official Piston API image
FROM ghcr.io/engineer-man/piston/api:latest

# 1. Set environment variables for internal and external communication
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# 2. Install the requested multi-language runtimes using the Piston installer
# We clean up /tmp after each major step to keep the build light for Render
RUN /piston/install python && \
    /piston/install node && \
    /piston/install java && \
    /piston/install cpp && \
    /piston/install go && \
    /piston/install rust && \
    /piston/install typescript && \
    /piston/install bash && \
    rm -rf /tmp/*

# 3. Copy the secure zero-dependency proxy file
# Ensure proxy.js is in the same directory as this Dockerfile
COPY proxy.js /piston/proxy.js

# 4. Create the startup script to sequence the engine and the proxy
RUN echo '#!/bin/sh\n\
echo "Starting Piston Engine on 127.0.0.1:3000..."\n\
node /piston/src/index.js & \n\
\n\
echo "Waiting 8 seconds for engine initialization..."\n\
sleep 8\n\
\n\
echo "Starting Neural Security Proxy on port 2000..."\n\
node /piston/proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

# 5. Expose the public proxy port
EXPOSE 2000

# 6. Initialize the secure execution stack
CMD ["sh", "/piston/start.sh"]
