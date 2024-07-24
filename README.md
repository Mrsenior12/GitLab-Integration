## To Do list
- [ ] GitLab:
    - [ ] Enable GitLab Container Registry
    - [ X ] Enable metrics for Cadvisor
    - [ X ] Enable metrics for Node Exporter
    - [ ] GitLab sample project to verify if CI/CD runs properly
- [ ] GitLab Runner:
    - [ ] Create Runner for docker
    - [ ] Add to script ability to generate them with single script execution
- [ ] Keycloak:
    - [ ] Create Realm for Grafana
    - [ ] Create Realm for GitLab (if possible)
- [ ] Grafana
    - [ ] Create Sample dashboard with repo monitoring
    - [ ] Create Sample dashboard with CI/CD monitoring
- [ ] Prometheus
    - [ ] Add rules for neccesery metrics for GitLab, Registry, etc.
- [ ] Nginx
    - [ ] Use Nginx as proxy server for GitLab and Grafana

## How to setup environment:
1. Clone repository
2. Inside repository execute following command:
```bash
# Script will create empty .env and creates necessary directories for each available service
./setup_environment.sh
```

## How to fill `.env` file:
1. Inside repository you'll find `./register_eunner.sh`. It's used to:
- fetch `root init password` from GitLab instance (file with this password will be removed automatically after 24h): `./register_runner.sh -i`
- change `root` user password, to password given by user: `./register_runner.sh -p <your_password>`
- create `Personal Access Tokens` `./register_runner.sh -t runner|exporter` with:
    - `read_api` permission (oprion `exporter`) required by GitLab-ci-pipeline-exporter
    - `create_runner` permission (option `runner`) required to register runners  

## How to setup GitLab-CI-pipeline-exporter with bash script:
1. Create and start GitLab instance
2. execute:
```bash
# Following command will generate Personal Access Token with read_api permission and save key value to .env file
./register_runner -t exporter
```
3. Restart `gitlab_ci_pipeline_exporter` service

## How to setup GitLab-CI-pipeline-exporter Manually:
1. Create and start GitLab instance
2. Log in to the GitLab
3. Go to `Edit profile` page
4. Go to `Access Tokens` section
5. Create new `Personal Access Token` with `read_api` permissions
6. Save value of that token under `PERSONAL_ACCESS_TOKEN` in `.env` file
7. Restart `gitlab_ci_pipeline_exporter` service


## Future Development
- [ ] Use Docker Swarm as method of running infrastructure
- [ ] Move project with Terraform to AWS


