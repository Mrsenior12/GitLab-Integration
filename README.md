## To Do list
- [ ] GitLab:
    - [ X ] Enable metrics for Cadvisor
    - [ X ] Enable metrics for Node Exporter
    - [ ] GitLab sample project to verify if CI/CD runs properly
- [ X ] GitLab Runner:
    - [ X ] Create Runner for docker
    - [ X ] Add to script ability to generate them with single script execution
- [ X ] Prometheus
    - [ X ] Add rules for neccesery metrics for GitLab, Registry, etc.
- [ ] Grafana
    - [ ] Create Sample dashboard with repo monitoring
    - [ ] Create Sample dashboard with CI/CD monitoring

## How to setup environment:
1. Clone repository
2. Inside repository execute following command:
```bash
# Script will create empty .env and creates necessary directories for each available service
./scripts/setup_environment.sh
```

## How to fill `.env` file:
1. Inside repository you'll find `./scripts/register_runner.sh`. It's used to:
- fetch `root init password` from GitLab instance (file with this password will be removed automatically after 24h): `./scripts/register_runner.sh -i`
- change `root` user password, to password given by user: `./scripts/register_runner.sh -p <your_password>`
- create `Personal Access Tokens` for exporter (with `read_api` permissions) `./scripts/register_runner.sh -t`
- register `docker:latest` Runner for `GitLab CI/CD` `./scripts/register_runner.sh -r`

## GitLab Runner:
Script `./scripts/register_runner.sh` allows to register `GitLab runner` programmatically by option `-r`. This option will create necessary `Personal Access Tokens` if they are not present in `.env` file. After that following option will register new `GitLab Runner` based on `docker:latest`. 

Unfortunately after In `GitLab 15.11` and later it's not possible to tag registered Runners. In order to tag them you have take do following steps:

1. Log into `GitLab` instance as an admin
2. Got to `Admin Area/Runners`
3. Select `Runner` you want to tag
4. Create Tag and save it

After this steps your `CI/CD` should be able to call `Runner` by its tag.

## How to setup GitLab-CI-pipeline-exporter with bash script:
1. Create and start GitLab instance
2. execute:
```bash
# Following command will generate Personal Access Token with read_api permission and save key value to .env file
./register_runner -t
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


