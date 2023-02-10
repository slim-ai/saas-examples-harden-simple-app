# Hardening Docker Workloads using Slim CLI

## The Problem and the Magic 🪄
Hello folks and if you are reading this, you might have already flashed a gaze at the picture below but before we come to that, let's take a look at the repository and it basically consists of just a simple (but huge) node app and a Dockerfile majorly. Now let's come back to the image (pun intended ofcourse) below again. The left side is what how the original image of our node app looks like and as visible, its huge 995 MB. Now what if we say that you can get the same app's hardened image with size minified to just 89 MB and vulnerabilites reduced by 99.67% and that too in just few simple steps? Sounds magical right? Well, so says the image on your right and that's the magic we are going to talk about today! 

![image](https://user-images.githubusercontent.com/45476902/218093055-50a44810-db1a-43fd-a71d-909e521d4a55.png)


### Prerequisites
* A fresh version of the Slim CLI is installed and configured as described on this [portal](https://portal.slim.dev/cli)

* Connector configured with Slim SaaS that will help you get your target image

* Docker (Engine or Desktop) is installed locally.

### Demo

#### Step 1: Instrument  🕵️

The first step involves instrumenting the image and simply speaking it means that the Slim engine's sensor is going to act like an intelligence agent (the Container's James Bond) to collect data for the further probe  🕵️


```sh
$ slim instrument \
  --include-path /etc/passwd \
  --stop-grace-period 999s  \
   ghcr.io/mritunjaysharma394/node-app:latest
```

**NOTE**: Make sure the instrumented image, in our case, `ghcr.io/mritunjaysharma394/node-app:latest-slim-instrumented` is available through the connector.

> Sometimes, the slim instrument command fails to find the target image even when it’s visible on the user portal. It is caused by the suboptimal heuristic that we use to map an image to a connector. You can mitigate it by explicitly specifying the connector ID using the --target-image-connector, --instrumented-image-connector, and --hardened-image-connector flags. The correspond connector ID can be copied from the connector editing page on the portal.

#### Step 2: Profile/probe/test  🔎

Now that we have our agent aka sensor in the target's territory, its time to implement the mission! That is let the container run using the instrumented image and get all the important data to harden it and reduce the vulnerablities in next step. 😎
 
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

Good job so far by the agent! Now that we have the data via automatically submitted reports, let's harden the target image and bring down its vulnerabilites and size 🚀:

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
Hurray, so you learnt the magic to harden your image quick right? It's time for celebration🍾

But wait, want too see all these steps in Actions? (Oh, we love puns!) So what are you waiting for?
Check out how it is implemented in the workflow of the GitHub actions and how you can implement the same in your CI/CD! 
