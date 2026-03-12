# Using the official Piston API image
FROM ghcr.io/engineer-man/piston/api:latest

# 1. Set environment variables
# Engine will run on 127.0.0.1:3000 (Internal)
# Proxy will run on $PORT (Default 2000 for Render)
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# 2. Set working directory to the Piston application root
WORKDIR /piston

# 3. Copy the secure zero-dependency proxy file
COPY proxy.js /piston/proxy.js

# 4. Create the startup script to sequence the engine and the proxy
# Piston API image already contains the necessary source files in /piston/src
RUN echo '#!/bin/sh\n\
echo "Initializing Piston Engine on 127.0.0.1:3000..."\n\
node /piston/src/index.js & \n\
\n\
echo "Waiting 8 seconds for engine setup..."\n\
sleep 8\n\
\n\
echo "Activating Security Proxy on port 2000..."\n\
node /piston/proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

# 5. Expose the public security boundary port
EXPOSE 2000

# 6. Initialize the secure execution stack
CMD ["sh", "/piston/start.sh"]
