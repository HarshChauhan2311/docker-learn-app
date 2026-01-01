# -------- Stage 1: Build Angular App --------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files for dependency installation
COPY package*.json ./
RUN npm ci --only=production=false

# Copy source code and build
COPY . .
RUN npm run build -- --configuration production

# -------- Stage 2: Nginx to Serve Angular --------
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy Angular build output (Angular 20+ outputs to dist/<project-name>/browser)
COPY --from=builder /app/dist/docker-learn-app/browser /usr/share/nginx/html

# Custom nginx config for Angular routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
