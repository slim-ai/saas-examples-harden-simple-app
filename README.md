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
How do you choose an optimal base image? 
How do you configure a multistage build to make the end image slim? 
How do you keep remove vulnerabilities from your images? 
One must be a true container expert to get it right. 

However, there is another way.

**Automated Container Image Hardening from Slim.AI**
With Slim.AI, you can: 

* Build an image FROM your favorite base.
* Instrument the image with the Slim Sensor.
* Run tests against the instrumented container and collect intelligence about what it needs to run.
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

The first step involves instrumenting the image and simply speaking it means that the Slim Sensor is going to act like an intelligence agent to collect data for the further probe.

```sh
$ slim instrument \
  --include-path /service \
  --stop-grace-period 30s  \
   ghcr.io/slim-ai/saas-examples-harden-simple-app:latest
...
rknx.2LkF7SjT3M0YbaXAMTjWgGm8zQN  # Instrumentation "attempt ID". Save this: you'll need it later.
```

**NOTE**: Make sure the instrumented image, in our case, `ghcr.io/slim-ai/saas-examples-harden-simple-app:latest` is available through the connector.

#### Step 2: Observe (_aka_ profile, _aka_ test)  🔎

Now that we have our agent (aka, the Slim Sensor) in the target container, it is time to implement the mission! 
That is, run the newly instrumented image and get all the important data Slim will need harden it. 😎
 
Make sure you use the `root` user and give the container ALL capabilities via the Docker run command. **NOTE:** This is required only for the instrumented container. Hardened containers won’t need any extra permissions. 

* Run the container: 

 ```sh
 $ docker run -d -p 8080:8080 --name app-inst \
   --user root \
   --cap-add ALL \
   ghcr.io/slim-ai/saas-examples-harden-simple-app:latest-slim-instrumented 
```

* “Test" the instrumented container. In the case of this simple app, merely running a curl against the running container will suffice. 

```sh
$ curl localhost:8080
```

By running curl, we see that the Node web app returns a response. Under the hood, the Slim Sensor observes the running container and collects intelligence about the required libraries, files, and binaries. 

* Stop the container gracefully, giving the sensor(s) enough time to finalize and submit the reports. **Note:** Failure to stop the container gracefully may result in a failed hardening process. 


```sh
$ docker stop -t 30 app-inst
```

#### Step 3: Harden  🔨

Now that we have the data via automatically submitted reports, let's harden the target image, removing any unnecessary components and thus reducing the total number of vulnerabilities, removing attack surface, and making it smaller. 

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
