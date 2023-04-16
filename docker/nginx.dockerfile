FROM nginx:stable-alpine

COPY --from=php-builder /app /usr/share/nginx/html

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080