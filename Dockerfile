# Use a small Node runtime
FROM node:18-alpine AS base
WORKDIR /app
ENV NODE_ENV=production

# install only production deps
FROM base AS deps
COPY package*.json ./
# use npm ci if package-lock exists
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --production; fi

# build step (if you have a build step; keeps layers clean)
FROM base AS runner
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# if your app listens on PORT env or default, keep it configurable
ENV PORT=3000
EXPOSE $PORT

CMD ["node", "server.js"]
