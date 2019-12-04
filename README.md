
## Kube-Pipework
**_A docker image of jpetazzo's pipework optimized for Kubernetes_**

![](https://img.shields.io/docker/build/kvaps/pipework.svg)

* **[Documentation](docs/0.%20Introduction.md)**
* **[Kubernetes example](docs/3.%20Examples.md#kubernetes)**
* **[DockerHub Page](https://registry.hub.docker.com/u/kvaps/pipework/)**

### Status

Actually this project is a fork of [dreamcat4/pipework](https://github.com/dreamcat4/docker-images/tree/master/pipework), it uses updated image and includes some fixes for make pipework working with Kubernetes annotations, and add [VLAN support for linux bridges](https://github.com/jpetazzo/pipework/pull/227).

Despite all the great features of Kubernetes, Pipework is still the easiest way to pastrough a static IP or physical interface into a container. Nevertheless, I would suggest you to avoid using pipework in situations where you can do without it.

Check **[bridget](https://github.com/kvaps/bridget/)** - this cni-plugin was created under impressed with Pipework, it is more native for Kubernetes and provides similar L2-network connectivity (except static IPs).

Of course you can use pipework with bridget together as well.

### Requirements

* Requires Docker 1.8.1
* Needs to be run in privileged mode etc.

### Credit

* [Pipework](https://github.com/jpetazzo/pipework) - Jerome Petazzoni
* Inspiration for the `host_routes` feature came from [this Article](http://blog.oddbit.com/2014/08/11/four-ways-to-connect-a-docker/), by Lars Kellogg-Stedman
* [Docker wrapper for Pipework](https://github.com/dreamcat4/docker-images/tree/master/pipework) - Dreamcat4
* [Kubernetes support](https://github.com/kvaps/kube-pipework) - kvaps
