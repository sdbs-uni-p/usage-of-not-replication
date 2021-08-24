# -----------------------------------------------------------------------------------------------------------------
# Replication package for "Usage of Not"
#
# Description: Postgres SQL database containing a corpus of over 80thousand JSON Schema documents,
#              collected from open source GitHub repositories.
# Version: 1.0
# License: Creative Commons Attribution 4.0 International License (https://creativecommons.org/licenses/by/4.0/)
# SPDX-License-Identifier: CC-BY-4.0
# Copyright: Copyright 2021 (c): Stefanie Scherzinger <stefanie.scherzinger@uni-passau.de>,
#            Copyright 2021 (c): Thomas Pilz <thomas.pilz@st.oth-regensburg.de>
# -----------------------------------------------------------------------------------------------------------------

# Start from long-term maintained base distribution
FROM ubuntu:18.04

#--- IMAGE DETAILS ---
LABEL maintainers="Stefanie Scherzinger <stefanie.scherzinger@uni-passau.de>, Thomas Pilz <thomas.pilz@st.oth-regensburg.de>"
LABEL version="1.0"
LABEL description="Postgres SQL database containing a corpus of over 80thousand JSON Schema documents,\
collected from open source GitHub repositories."
LABEL license="Creative Commons Attribution 4.0 International License (https://creativecommons.org/licenses/by/4.0/)"
LABEL copyright="Copyright 2021 (c): Stefanie Scherzinger <stefanie.scherzinger@uni-passau.de>, Copyright 2021 (c): Thomas Pilz <thomas.pilz@st.oth-regensburg.de>"
LABEL spdx-license-identifier="CC-BY-4.0"

#--- ENVIRONMENT VARIABLES ---
# For details on environment variables refer to README.md
# Configure OS environment
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV ROOT_PW="password"
# Create user with password and a database
ENV POSTGRES_USER="root"
ENV POSTGRES_PASSWORD="password"
ENV POSTGRES_DB="jsonschemacorpus"
ENV POSTGRES_PORT=5432
# PostgreSQL major version
ENV PG_MAJOR_VERSION=12
# Name of SQL-Dump file (used in setup.sh)
ENV SQL_DUMP_FNAME="jsonschemacorpus_dump.sql"
# Name of directory where data etc. are stored
ENV WORKDIR=/json-schema-corpus
# Inlude postgres executables in path
ENV PATH=${PATH}:/usr/lib/postgresql/${PG_MAJOR_VERSION}/bin

# 1. Make en_GB.UTF-8 locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_GB -c -f UTF-8 -A /usr/share/locale/locale.alias en_GB.UTF-8
ENV LANG en_GB.utf8

# 2. Install utilities
RUN set -ex; \
    apt update && apt install -y --no-install-recommends \
    ca-certificates \
    gnupg2 \
    gzip \
    nano \ 
    vim \  
    wget

# 3. Get pgp key for postgres repo
RUN set -x; \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# 4. Install postgres
RUN set -ex; \
    apt-get update \
    && apt-get -y install --no-install-recommends \
    postgresql-${PG_MAJOR_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# 4. Configure postgres
USER postgres
RUN set -ex; \
    # Start postgres service
    /etc/init.d/postgresql start \
    # Enable trust authentication so no password is required
    && echo "host all all all trust" >> /etc/postgresql/${PG_MAJOR_VERSION}/main/pg_hba.conf \
    # Allow remote connections
    && echo "listen_addresses='*'" >> /etc/postgresql/${PG_MAJOR_VERSION}/main/postgresql.conf \
    # Change port (service will be restarted later)
    && sed -i "s/port = 5432/port = ${POSTGRES_PORT}/g" /etc/postgresql/${PG_MAJOR_VERSION}/main/postgresql.conf \
    # Create postgres superuser
    && psql -c "CREATE USER ${POSTGRES_USER} WITH SUPERUSER PASSWORD '${POSTGRES_PASSWORD}';" \
    # Create database with created user 
    && createdb -O ${POSTGRES_USER} ${POSTGRES_DB} "Corpus of over 80thousand JSON schema documents" \
    # Update search_path to include schema "jsonnegation" which will be created by restore
    && psql -c "ALTER DATABASE ${POSTGRES_DB} SET search_path = jsonnegation, \"\$user\", public;" \
    # Shutdown Postgres service again otherwise it will not exit properly
    && /etc/init.d/postgresql stop
USER root
    

# 5. Set the default STOPSIGNAL to SIGINT, which corresponds to what PostgreSQL
# calls "Fast Shutdown mode" wherein new connections are disallowed and any
# in-progress transactions are aborted, allowing PostgreSQL to stop cleanly and
# flush tables to disk, which is the best compromise available to avoid data
# corruption.
# See https://www.postgresql.org/docs/12/server-shutdown.html for more details
# about available PostgreSQL server shutdown signals.
STOPSIGNAL SIGINT

# 6. Make working directory for required files
RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

# 7. Copy SQL dump
COPY ./${SQL_DUMP_FNAME}.gz ./${SQL_DUMP_FNAME}.gz

# 8. Copy init script
COPY ./scripts/init.sh ./scripts/init.sh

# 9. Restore data from SQL-dump
RUN set -ex; \
    # Verify SQL-dump was downloaded correctly and stop build (exit code 1) if not
    echo "9609b35fffe654fc3379773492ee4fac1c519193f646c6fa50390eaefd08e4df ./${SQL_DUMP_FNAME}.gz" | sha256sum -c \
    # SQL-Dump invalid -> stop build
    || { \
    echo -e "\n\n\033[0;91mERROR\033[0m SQL dump SHA-256 hash invalid. Please make sure ${SQL_DUMP_FNAME}.gz is downloaded properly from git lfs. \
    \n\033[0;91m>\033[0m Expected hash: 9609b35fffe654fc3379773492ee4fac1c519193f646c6fa50390eaefd08e4df \
    \n\033[0;91m>\033[0m Expected filesize: 1475453498\n" && exit 1; }; \
    # Execute restore script
    ./scripts/init.sh

# 10. Copy SQL-scripts
COPY ./sql-queries ./sql-queries/

# 11. Expose postgres port
EXPOSE ${POSTGRES_PORT}

# 12. Copy rest of the scripts
COPY ./scripts/ ./scripts/

# 13. Postgres must be started as user postgres
USER postgres

# 14. Executed on "docker run": Start postgres server in foreground
ENTRYPOINT ./scripts/entrypoint.sh
