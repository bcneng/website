# BcnEng
[![Netlify Status](https://api.netlify.com/api/v1/badges/f31a7adf-da08-42fa-a419-053fe7765e0d/deploy-status)](https://app.netlify.com/sites/bcneng/deploys)

[BcnEng](http://bcneng.org) is a slack community built around the software engineering community from Barcelona.

You can get an invitation to join it [here](http://slack.bcneng.org).

## Developers

This repository hosts the code to build the static website using [Hugo](https://gohugo.io/).

To get started and contribute to its growth, you only need to clone the repository, including its submodules, and fire a `docker run` command.

More precisely, the instructions to start the server locally are:

    git clone --recursive git@github.com:bcneng/bcneng.github.io.git
    cd bcneng.github.io

Make sure the folder `themes/chunky-poster` is populated. Otherwise do a:

    git submodule init
    git submodule update

  Temporarily while this site is not published, you need to use the `bcneng-v2` branch:

    git checkout bcneng-v2

Then you can start the server:

    docker run --rm -it -v "$PWD:/site" -p "1313:1313" alombarte/hugo hugo server -D --bind 0.0.0.0

If you prefer having Hugo [installed locally](https://gohugo.io/getting-started/installing/), you can simply do:

	hugo server -D

The service will be available on [localhost:1313](http://localhost:1313) in both cases unless the port is already in use.

Thanks for contributing!
