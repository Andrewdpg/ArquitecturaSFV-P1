FROM node:20-alpine

WORKDIR /app

# Copiar Package.json
COPY package.json .

# Instalar dependencias
RUN npm install

# Copiar el resto del código
COPY . .

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "start"]
