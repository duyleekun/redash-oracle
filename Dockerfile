FROM redash/redash:8.0.0.b32245

USER root

RUN apt-get update  -y
RUN apt-get install -y unzip
RUN apt-get install -y libaio-dev  # depends on Oracle
RUN apt-get clean -y

# -- Start setup Oracle
# Add instantclient

RUN wget https://download.oracle.com/otn_software/linux/instantclient/195000/instantclient-basiclite-linux.x64-19.5.0.0.0dbru.zip -O /tmp/instantclient-basiclite-linux.x64-19.5.0.0.0dbru.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/195000/instantclient-sqlplus-linux.x64-19.5.0.0.0dbru.zip -O /tmp/instantclient-sqlplus-linux.x64-19.5.0.0.0dbru.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/195000/instantclient-tools-linux.x64-19.5.0.0.0dbru.zip -O /tmp/instantclient-tools-linux.x64-19.5.0.0.0dbru.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/195000/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip -O /tmp/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip \
    && mkdir -p /opt/oracle/ \
    && unzip /tmp/instantclient-basiclite-linux.x64-19.5.0.0.0dbru.zip -d /opt/oracle/ \
    && unzip /tmp/instantclient-sqlplus-linux.x64-19.5.0.0.0dbru.zip -d /opt/oracle/ \
    && unzip /tmp/instantclient-tools-linux.x64-19.5.0.0.0dbru.zip -d /opt/oracle/  \
    && unzip /tmp/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip -d /opt/oracle/  \
    && rm /tmp/instantclient*

ENV ORACLE_HOME=/opt/oracle/instantclient_19_5/
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_5/:$LD_LIBRARY_PATH
ENV PATH=/opt/oracle/instantclient_19_5/:$PATH

# Add REDASH ENV to add Oracle Query Runner
ENV REDASH_ADDITIONAL_QUERY_RUNNERS=redash.query_runner.oracle
# -- End setup Oracle

# Only 7+ supports 19.x instantclient
RUN echo "cx_Oracle==7.3.0" > requirements_oracle_ds.txt

# We first copy only the requirements file, to avoid rebuilding on every file
# change.
#COPY requirements.txt requirements_dev.txt requirements_all_ds.txt requirements_oracle_ds.txt ./
RUN pip install -r requirements.txt -r requirements_dev.txt -r requirements_all_ds.txt -r requirements_oracle_ds.txt

#COPY . ./
#RUN npm install && npm run build && rm -rf node_modules
#RUN chown -R redash /app
USER redash

ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["server"]
