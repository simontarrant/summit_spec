FROM postgres:16-alpine

# Install PostgreSQL extensions
RUN apk add --no-cache postgresql-contrib

# Create init directory
COPY ./init-scripts /docker-entrypoint-initdb.d/

# Default locale and encoding
ENV LANG=en_US.utf8
ENV LC_ALL=en_US.utf8
