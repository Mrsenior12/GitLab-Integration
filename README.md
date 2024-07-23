## To Do list
- [ ] GitLab:
    - [ ] Enable GitLab Container Registry
    - [ X ] Enable metrics for Cadvisor
    - [ X ] Enable metrics for Node Exporter
    - [ ] GitLab sample project to verify if CI/CD runs properly
- [ ] GitLab Runner:
    - [ ] Create Runner for docker
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

## How to setup GitLab-CI-pipeline-exporter

1. Create and start GitLab instance
2. Log in to the GitLab
3. Go to `Edit profile` page
4. Go to `Access Tokens` section
5. Create new `Personal Access Token` with `read_api` permissions
6. Save value of that token under `PERSONAL_ACCESS_TOKEN` in `.env` file
7. Restart `gitlab_ci_pipeline_exporter` container


## Future Development
- [ ] Use Docker Swarm as method of running infrastructure
- [ ] Move project with Terraform to AWS


