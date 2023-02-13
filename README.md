# Primer: a Node.js Application Hardening

The repository includes:

- A simple server application written in Node.js.
- A typical Dockerfile to containerize it.
- A workflow to build and push the (pretty big) image.
- A workflow to _harden_ that image.

## The Problem and the Solution 

Creating high-quality container images is hard. How to choose an optimal base image? 
How to configure a multistage build to make the end image slim? 
How to keep the vulnerability scanners calm? 
One must be a true container expert to get it right. 
However, there might be an alternative way.

**Automated container image hardening**

* Build an image FROM your favorite base.
* Instrument the image with our sensors.
* Run an instrumented container "probing" its functionality.
* Build a hardened version of the image using collected intelligence.

![image](https://user-images.githubusercontent.com/45476902/218093055-50a44810-db1a-43fd-a71d-909e521d4a55.png)


### Prerequisites
* A fresh version of the Slim CLI [installed and configured](https://portal.slim.dev/cli)

* [A container registry connector configured](https://portal.slim.dev/connectors)

* An ability to run the instrumented image (e.g., using Docker or Kubernetes)

### Demo

Before we move to the steps, let's visualise how the flow looks like!
![image](https://user-images.githubusercontent.com/45476902/218159028-d2b21334-bfeb-45dd-8d2d-725fbe3d3520.png)


#### Step 1: Instrument  🕵️

The first step involves instrumenting the image and simply speaking it means that the Slim engine's sensor is going to act like an intelligence agent to collect data for the further probe  🕵️


```sh
$ slim instrument \
  --include-path /etc/passwd \
  --stop-grace-period 999s  \
   ghcr.io/mritunjaysharma394/node-app:latest
```

**NOTE**: Make sure the instrumented image, in our case, `ghcr.io/mritunjaysharma394/node-app:latest-slim-instrumented` is available through the connector.

#### Step 2: Profile/probe/test  🔎

Now that we have our agent aka sensor in the target's territory, its time to implement the mission! 
That is let the container run using the instrumented image and get all the important data to harden it and reduce the vulnerablities in next step. 😎
 
Make sure you use the root user and give it ALL capabilities (notice that this is a requirement only for the instrumented containers - hardened containers won’t need any extra permissions):
* Run the container: 
 ```sh
 $ docker run -d --rm \
   --user root \
   --cap-add ALL \
   -p 8080:8080 \
   --name app-instrumented ghcr.io/mritunjaysharma394/node-app:latest-slim-instrumented 
  ```
* “Probe” the instrumented node app container:
```sh
$ curl localhost:8080
```

* Stop the container gracefully giving the sensor(s) enough time to finalize and submit the reports:


```sh
$ docker stop -t 999 app-instrumented
```
#### Step 3: Hardening  🔨

Good job so far by the agent! 
Now that we have the data via automatically submitted reports, let's harden the target image and bring down its vulnerabilites and size 🚀:

* Let's get the NX ID

```sh
$ NX_ID=$(docker inspect --format '{{ index .Config.Labels "slim.nx"}}' ghcr.io/mritunjaysharma394/node-app:latest-slim-instrumented)
```

* Harden using the NX ID
```sh
$  slim harden --id $NX_ID
```

#### Step 4: Verify  ✔

* Run a new container using the hardened image (notice that it doesn’t require any extra privileges):

```sh
$ docker run -d --rm \
  -p 8081:8080 \
  --name app-hardened ghcr.io/mritunjaysharma394/node-app:latest-slim-hardened
 ```
 
* Verify that the hardened image works:

```sh
$ curl localhost:8081
```

#### Step 5: Clean up 🧹


```sh
$ docker stop app-hardened
```
### Time for Actions
Hurray, so you learnt the magic to harden your image quick right? 
It's time for celebration🍾

But wait, want too see all these steps in Actions? (Oh, we love puns!) So what are you waiting for?
Check out how it is implemented in the [workflow of the GitHub actions](https://github.com/mritunjaysharma394/ich-examples/actions) and how you can implement the same in your CI/CD! 
