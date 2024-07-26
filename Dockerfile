FROM node:18 AS node_stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
RUN apk add --no-cache nodejs npm
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=node_stage /app/dist /app/dist
EXPOSE 80 4000
CMD ["sh", "-c", "node /app/dist/ssr-nginx-poc/server/server.mjs & nginx -g 'daemon off;'"]
