# customize-sonarqube-docker

Customize the official Sonarqube Dockerfile, the latest version based on official sonarqube:
8.8.9-community image.

## Attention for embedded Elasticsearch

### ulimits
You must increase ulimits for nofile and nproc when execute `docker run`, see [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html).
```bash
--ulimit nofile=65535:65535 --ulimit nproc=65535:65535
```

### vm.max_map_count
The embedded Elasticsearch must set `vm.max_map_count` at least to `262144`, [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html).

You can skip this step, because already set to `/etc/sysctl.conf` during image build.
```dockerfile
USER root
RUN sed -i '$a\vm.max_map_count=262144' /etc/sysctl.conf \
```

## Test
You can build and run with embedded database and elasticsearch very simple.
```bash
docker build --layers --force-rm --tag customize-sonarqube .

docker run -d \
  -p 9000:9000 \
  --name customize-sonarqube-test \
  --ulimit nofile=65535:65535 \
  --ulimit nproc=65535:65535 \
  customize-sonarqube
```