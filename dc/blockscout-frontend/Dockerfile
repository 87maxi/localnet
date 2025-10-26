# Imagen base de Node.js (liviana)
FROM node:22.11.0-alpine
RUN apk add --no-cache git wget

WORKDIR /app

COPY ./frontend /app


EXPOSE 3000



# Comando por defecto
CMD ["yarn", "start"]