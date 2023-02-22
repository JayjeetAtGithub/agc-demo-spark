1. Install `docker` and `docker-compose`.
```bash
curl -o- https://get.docker.com | bash
apt-get install docker-compose-plugin
```

2. Clone the docker-spark-iceberg repo.
```bash
git clone https://github.com/JayjeetAtGithub/docker-spark-iceberg
```

3. Bring up the services.
```bash
cd docker-spark-iceberg/
docker compose up -d
```

4. Navigate to `hostname:8888` to access the Jupyter notebook.

5. Open a terminal from Jupyter, and clone this repository.

6. Execute `create_dataset.sh` and then run the notebook.
