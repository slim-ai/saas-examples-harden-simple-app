# Primer: a Node.js Application Hardening

The repository includes:

- A simple server application written in Node.js.
- A typical Dockerfile to containerize it.
- [A workflow to build and push the (pretty big) image](.github/workflows/build.yaml).
- [A workflow to optimize and _harden_ this image](.github/workflows/harden.yaml).
- [Examples of the input and output images](https://github.com/slim-ai/saas-examples-harden-simple-app/pkgs/container/saas-examples-harden-simple-app).

The application code is straightforward and the workflows are well-documented.
You can explore the repository, then clone it, and adapt it for your use cases. 

## The Problem and the Solution 

Creating high-quality container images is no easy task.
How to choose an optimal base image? 
How to configure a multistage build to make the end image slim? 
How to keep the vulnerability scanners calm? 
One must be a true container expert to get it right. 
However, there might be an alternative way.

**Automated container image hardening**

* Build an image FROM your favorite base.
* Instrument the image with Slim sensors.
* Run an instrumented container "probing" its functionality.
* Build a hardened version of the image using collected intelligence.

![image](https://user-images.githubusercontent.com/45476902/218093055-50a44810-db1a-43fd-a71d-909e521d4a55.png)

## Demo: Hardening a container image using Slim CLI

### Prerequisites

* A fresh version of the Slim CLI [installed and configured](https://portal.slim.dev/cli)

* [A container registry connector configured](https://portal.slim.dev/connectors)

* An ability to run the instrumented image (e.g., using Docker or Kubernetes)

### What & How

Before we move to the steps, let's see how the flow can be visualized:

![image](https://user-images.githubusercontent.com/45476902/218159028-d2b21334-bfeb-45dd-8d2d-725fbe3d3520.png)


#### Step 1: Instrument  🕵️

The first step involves instrumenting the image and simply speaking it means that the Slim engine's sensor is going to act like an intelligence agent to collect data for the further probe  🕵️

```sh
$ slim instrument \
  --include-path /service \
  --stop-grace-period 30s  \
   ghcr.io/slim-ai/saas-examples-harden-simple-app:latest
...
rknx.2LkF7SjT3M0YbaXAMTjWgGm8zQN  # Instrumentation "attempt ID", you'll need it later.
```

**NOTE**: Make sure the instrumented image, in our case, `ghcr.io/slim-ai/saas-examples-harden-simple-app:latest` is available through the connector.

#### Step 2: Probe (_aka_ profile, _aka_ test)  🔎

Now that we have our agent aka sensor in the target's territory, its time to implement the mission! 
That is let the container run using the instrumented image and get all the important data to harden it and reduce the vulnerabilities in next step. 😎
 
Make sure you use the root user and give it ALL capabilities (notice that this is a requirement only for the instrumented containers - hardened containers won’t need any extra permissions):

* Run the container: 

 ```sh
 $ docker run -d -p 8080:8080 --name app-inst \
   --user root \
   --cap-add ALL \
   ghcr.io/slim-ai/saas-examples-harden-simple-app:latest-slim-instrumented 
```

* “Probe” the instrumented container:

```sh
$ curl localhost:8080
```

* Stop the container gracefully giving the sensor(s) enough time to finalize and submit the reports:


```sh
$ docker stop -t 30 app-inst
```

#### Step 3: Harden  🔨

Now that we have the data via automatically submitted reports, let's harden the target image and bring down its vulnerabilities and size 🚀:

Harden using the ID obtained on the **Instrument** step:

```sh
$ slim harden --id <instrumentation attempt ID>
```

#### Step 4: Verify  ✔

* Run a new container using the hardened image (notice that it doesn't require any extra privileges):

```sh
$ docker run -d -p 8080:8080 --name app-hard \
  ghcr.io/slim-ai/saas-examples-harden-simple-app:latest-slim-hardened
```
 
* Verify that the hardened image works:

```sh
$ curl localhost:8080
```
