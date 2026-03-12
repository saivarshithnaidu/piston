# Using the official Piston API image
FROM ghcr.io/engineer-man/piston/api:latest

# 1. Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# 2. Set working directory
WORKDIR /piston

# 3. Install requested runtimes using the local installer binary
# Cleaning up /tmp after each run helps prevent disk overflow on Render Free Tier
RUN ./install python && \
    ./install node && \
    ./install java && \
    ./install cpp && \
    ./install go && \
    ./install rust && \
    ./install typescript && \
    ./install bash && \
    rm -rf /tmp/*

# 4. Copy the secure zero-dependency proxy
COPY proxy.js /piston/proxy.js

# 5. Create the startup script to sequence the engine and the proxy
RUN echo '#!/bin/sh\n\
echo "Booting Piston Logic Core on 127.0.0.1:3000..."\n\
node /piston/src/index.js & \n\
\n\
echo "Allowing 10s for neural synchronization..."\n\
sleep 10\n\
\n\
echo "Activating Security Proxy on port 2000..."\n\
node /piston/proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

# 6. Expose the security boundary port
EXPOSE 2000

# 7. Initialize secure stack
CMD ["sh", "/piston/start.sh"]
