# FROM node:20
# # creates /app and set the directory to /app
# WORKDIR /app 
# COPY package.json .
# COPY *.js .
# RUN npm install
# ENV MONGO_URL="mongodb://mongodb:27017/catalogue" \ 
#     MONGO="true"
# CMD ["node", "server.js"]

FROM node:20.20.2-alpine3.22 AS builder 
# creates /app and set the directory to /app
WORKDIR /app 
COPY package.json .
COPY *.js .
# node_modules 
RUN npm install

# FROM node:20.20.2-alpine3.22
# WORKDIR /app 
# COPY --from=builder /app /app 
# EXPOSE 8080 
# ENV MONGO_URL="mongodb://mongodb:27017/catalogue" \ 
#     MONGO="true"
# RUN addgroup -S roboshop && adduser -S -G roboshop roboshop 
# RUN chown -R roboshop:roboshop /app 
# USER roboshop 
# CMD ["node", "server.js"]

FROM node:20.20.2-alpine3.22
WORKDIR /app 
EXPOSE 8080 
ENV MONGO_URL="mongodb://mongodb:27017/catalogue" \ 
    MONGO="true"
RUN addgroup -S roboshop && adduser -S -G roboshop roboshop && \
    chown -R roboshop:roboshop /app 
COPY --from=builder /app /app 
# as this layer will be changed when there is a code change so we will place this at last to reduce disturbance in layers
USER roboshop 
CMD ["node", "server.js"]
