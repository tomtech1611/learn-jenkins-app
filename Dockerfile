FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y nodejs

RUN node --version && npm --version
RUN npm install -g netlify-cli node-jq serve
