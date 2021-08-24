#!/bin/bash
#--------------------------------------------------------------------+
# Entrypoint for the the container. Run on container startup.        |
#                                                                    |
# Author: Thomas Pilz (Thomas.Pilz@st.oth-regensburg.de)             |
#--------------------------------------------------------------------+

# Start postgres in foreground
postgres -c config_file=/etc/postgresql/${PG_MAJOR_VERSION}/main/postgresql.conf
