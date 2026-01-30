# --- STAGE 1: Build ---
FROM node:20-slim AS build

# Install pnpm globally
RUN npm install -g pnpm

WORKDIR /app

# Copy lockfile and package.json first to leverage Docker caching
COPY pnpm-lock.yaml package.json ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of your code and build the project
COPY . .
RUN pnpm run build

# --- STAGE 2: Serve ---
FROM nginx:alpine AS runtime

# Copy the build output from the first stage to Nginx's html folder
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]