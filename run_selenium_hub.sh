#!/bin/bash -v
# Reproduces https://github.com/SeleniumHQ/selenium/issues/3927
find . \( -name \*.pyc -o -name \*.pyo -o -name __pycache__ \) -prune -exec rm -rf {} +
docker build -t kuma-integration-tests:issue3927 --pull=true -f DockerfileIntegrationTests .
docker run -d --name selenium-hub-3927 selenium/hub:3.4.0
docker run -d --name selenium-node-ff-3927 --link selenium-hub-3927:hub selenium/node-firefox:3.4.0
docker run --link selenium-hub-3927:hub kuma-integration-tests:issue3927 sh -c 'py.test tests/functional/test_home.py --driver Remote --capability browserName firefox --host hub --base-url=https://developer.allizom.org -m "not login"'
docker stop selenium-node-ff-3927
docker rm --volumes selenium-node-ff-3927
docker stop selenium-hub-3927
docker rm --volumes selenium-hub-3927
