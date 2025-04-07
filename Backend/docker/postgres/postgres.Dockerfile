FROM postgres

RUN echo "listen_addresses='*'" >> /etc/postgresql/postgresql.conf

EXPOSE 5432

CMD ["postgres"]
