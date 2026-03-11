# Using the official Piston API image
FROM ghcr.io/engineer-man/piston/api:latest

# Set environment variables
ENV PORT=2000
ENV PISTON_BIND_ADDR=127.0.0.1:3000

# Install proxy dependencies
RUN npm install http-proxy

# Install the language runtimes
RUN /piston/index.sh && \
    /piston/install.sh python && \
    /piston/install.sh node && \
    /piston/install.sh java && \
    /piston/install.sh cpp

# Copy the security proxy
COPY proxy.js /piston/proxy.js

# Create a startup script
RUN echo '#!/bin/bash\n\
node src/index.js & \n\
sleep 5 && node proxy.js\n\
' > /piston/start.sh && chmod +x /piston/start.sh

EXPOSE 2000
CMD ["/piston/start.sh"]
