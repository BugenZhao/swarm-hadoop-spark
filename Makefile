%.deploy:
	docker stack deploy -c ./docker-compose-$*.yml $*

%.ps:
	watch -n 1 docker stack ps $*

%.rm:
	docker stack rm $*

INPUT := ./data/London2013.csv

HADOOP_NAMENODE := $(shell docker ps -a --format "{{.Names}}" | grep namenode)
HADOOP_APP := ss_hadoop.jar

hadoop.bash:
	docker exec -it $(HADOOP_NAMENODE) bash

hadoop.run:
	docker cp $(HADOOP_APP) $(HADOOP_NAMENODE):/tmp/$(HADOOP_APP)
	docker cp $(INPUT) $(HADOOP_NAMENODE):/tmp/input.txt
	docker exec -it $(HADOOP_NAMENODE) bash -c '\
		ls /tmp/$(HADOOP_APP) -al;\
		rm -rf /tmp/output/;\
		hdfs dfs -copyFromLocal -f /tmp/input.txt /input.txt;\
		hdfs dfs -rm -f -r /output;\
		$$HADOOP_HOME/bin/hadoop jar /tmp/$(HADOOP_APP) /input.txt /output;\
		hdfs dfs -copyToLocal /output/ /tmp/output;\
		head -n 10 /tmp/output/*;\
	'


SPARK_WORKER := $(shell docker ps -a --format "{{.Names}}" | grep worker)

spark.bash:
	docker exec -it $(SPARK_WORKER) bash
