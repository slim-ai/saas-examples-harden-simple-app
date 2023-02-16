# Primer: a Node.js Application Hardening

The repository includes:

- A simple server application written in Node.js.
- A typical Dockerfile to containerize it.
- [A workflow to build and push the (very large) image to a registry](.github/workflows/build.yaml).
- [A workflow to optimize and _harden_ this image](.github/workflows/harden.yaml).
- [Examples of the input and output images](https://github.com/slim-ai/saas-examples-harden-simple-app/pkgs/container/saas-examples-harden-simple-app).

The application code is straightforward and the Workflow files are heavily commented.

You can explore this repository, and then clone it and adapt it to your application. 

## The Problem and the Solution 

Creating high-quality container images is no easy task. 

How do you choose an optimal base image? How do you configure a multistage build? How do you remove vulnerabilities from your images? One must be a true container expert to get it right. 

However, there is another way.

**Automated Container Image Hardening from Slim.AI**
With Slim.AI, you can: 

* Build an image FROM your favorite base.
* Instrument the image with the Slim Sensor.
* Run tests against the instrumented container to collect intelligence about what it needs to run.
* Build a hardened version of the image using that intelligence.

![Results from Container Image Hardening](https://user-images.githubusercontent.com/45476902/218093055-50a44810-db1a-43fd-a71d-909e521d4a55.png)

## Hardening a container image using the Slim CLI

### Prerequisites
To complete this tutorial, you will need: 

* A fresh version of the Slim CLI installed and configured [link](https://portal.slim.dev/cli) / [docs]()

* A container registry connector configured via the Slim SaaS [link](https://portal.slim.dev/connectors) / [docs](https://www.slim.ai/docs/connectors) 

* The ability to run the instrumented image (e.g., using Docker or Kubernetes)

### What & How

Before we move to the steps, let's see how the flow can be visualized:

![Diagram of the Hardening Process](https://user-images.githubusercontent.com/45476902/218159028-d2b21334-bfeb-45dd-8d2d-725fbe3d3520.png)


#### Step 1: Instrument  🕵️

The first step involves instrumenting the image. Simply speaking, this means adding the Slim Sensor to your container so it can act as an intelligence agent to collect data during the `Observe` step.

```sh
$ slim instrument \
  --include-path /service \
  --stop-grace-period 30s  \
   ghcr.io/slim-ai/saas-examples-harden-simple-app:latest
...
rknx.2LkF7SjT3M0YbaXAMTjWgGm8zQN  # Instrumentation "attempt ID". Save this: you'll need it later.
```

**NOTE**: Make sure the instrumented image, in our case, `ghcr.io/slim-ai/saas-examples-harden-simple-app:latest` is available through the connector.

#### Step 2: Observe (_aka_ "profile" _aka_ "test")  🔎

Now that we have our agent (aka, the Slim Sensor) in the target container, it is time to implement the mission. That is, to run the newly instrumented image and get all the data Slim will need to harden it. 😎
 
You'll need to run the instrumented container as the `root` user and give it ALL capabilities via the Docker run command. 

 ```sh
 $ docker run -d -p 8080:8080 --name app-inst \
   --user root \
   --cap-add ALL \
   ghcr.io/slim-ai/saas-examples-harden-simple-app:latest-slim-instrumented 
```

**NOTE:** This is required only for the instrumented container. Hardened containers won’t need any extra permissions. 

“Test" the instrumented container — the Slim process needs the container to be exercised in some way to trigger the Observations. In the case of this simple app, merely running a `curl` request against the running container will suffice. In reality, integration tests in a test or staging environment are the most common. 

```sh
$ curl localhost:8080
```

By running curl, we see that the Node web app returns a response. Under the hood, the Slim Sensor observes the running container and collects intelligence about the required libraries, files, and binaries. 

Finally, we stop the container gracefully, giving the sensor(s) enough time to finalize and submit the reports. Failure to stop the container gracefully may result in a failed hardening process. 

```sh
$ docker stop -t 30 app-inst
```

#### Step 3: Harden  🔨

Now that we have the data via automatically submitted reports, we can harden the target image, removing unnecessary components and thus reducing the overall vulnerability count and attack surface. 

Harden using the ID obtained on the **Instrument** step:

```sh
$ slim harden --id <instrumentation attempt ID>
```

#### Step 4: Verify  ✔

Run a new container using the hardened image (notice that it doesn't require any extra privileges):

```sh
$ docker run -d -p 8080:8080 --name app-hard \
  ghcr.io/slim-ai/saas-examples-harden-simple-app:latest-slim-hardened
```
 
Verify that the hardened image works by re-running tests. 

```sh
$ curl localhost:8080
```

Interested in learning more? Check out our [Solutions page](https://www.slim.ai/solutions). 
