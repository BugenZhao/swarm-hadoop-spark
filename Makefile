%.deploy:
	docker stack deploy -c ./docker-compose-$*.yml $*

%.ps:
	watch -n 1 docker stack ps $*

%.rm:
	docker stack rm $*



HADOOP_NAMENODE := $(shell docker ps -a --format "{{.Names}}" | grep namenode)
APP := wc.jar

hadoop.bash:
	docker exec -it $(HADOOP_NAMENODE) bash

hadoop.wc:
	docker cp $(APP) $(HADOOP_NAMENODE):/tmp/$(APP)
	docker exec -it $(HADOOP_NAMENODE) bash -c '\
		hdfs dfs -mkdir -p /input/;\
		hdfs dfs -copyFromLocal -f /opt/hadoop-3.2.1/README.txt /input/;\
		hdfs dfs -rm -f -r /output/; \
		$$HADOOP_HOME/bin/hadoop jar /tmp/$(APP) WordCount /input /output;\
	'


SPARK_WORKER := $(shell docker ps -a --format "{{.Names}}" | grep worker)

spark.bash:
	docker exec -it $(SPARK_WORKER) bash
