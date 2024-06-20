## Running Dalgo Locally
Below are the steps to follow to run all dalgo components:

### Step 1: Install docker 
- Install [docker](https://docs.docker.com/engine/install/)
- Install [docker-compose](https://docs.docker.com/compose/install/)

### Step 2: Start airbyte

Open another terminal that you will use to run airbyte

#### Install abctl

To install the package, follow this [instructions](https://github.com/airbytehq/abctl)

- `make start-airbyte`

username is foo and password is bar

### Step 3: Make sure you have built the images of all the services

#### For Developers who want to test Dalgo for the first time without cloning other repos

- `make image-all`

For developers who are actively working on dalgo code and have atleast one image locally, you can build the images that you do not have locally. Remember to change the image name in the Dockerfile to reference your local image name

- `make image-frontend`

- `make image-backend`

### Step 4: Run docker compose

- `make compose-up`

### Step 5: Stop Containers

- `make container-down`


