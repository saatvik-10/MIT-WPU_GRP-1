FROM oven/bun:latest

WORKDIR /app

COPY ./package.json ./package.json
COPY ./bun.lock ./bun.lock

RUN bun run install --frozen-lockfile

COPY . .

RUN bunx prisma generate

EXPOSE 8080

CMD [ "bun", "run", "dev:docker" ]