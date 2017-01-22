FROM tutum/lamp:latest
RUN apt-get update && apt-get install -y php5-gd
EXPOSE 80 3306
CMD ["/run.sh"]