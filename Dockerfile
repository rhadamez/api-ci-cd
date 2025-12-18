FROM node:24 AS build

WORKDIR /usr/src/app

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn

COPY . .

RUN yarn build
RUN yarn install --production && yarn cache clean

#Execution

FROM node:24-alpine3.23

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/yarn.lock ./yarn.lock
COPY --from=build /usr/src/app/.yarn ./.yarn
COPY --from=build /usr/src/app/.yarnrc.yml ./.yarnrc.yml

RUN yarn install --production --frozen-lockfile && yarn cache clean

EXPOSE 3000

CMD ["node", "dist/main.js"]
