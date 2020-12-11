# Home Assistant OpenVPN Client Add-On

This is a Add-On for [Home Assistant](https://www.home-assistant.io) which enables to tunnel the communication of your
Home Assistant server with the world through a VPN connection.

This Add-On is interesting especially for those of you having a Google Home Mini and/or Amazon Alex integrated into your
local Home Assistant but don't want to expose it into the world and already have a trustworthy remote server with a ssl
certificate (acquired e.g. using [Certbot](https://certbot.eff.org/)).

The initial version of the Dockerfile to install the openvpn client was created by [TheSkorm](https://github.com/TheSkorm).
Thanks for this. Base on his work, I've added the following:

* The Addon-On will now ship with its own website based on [Flask](http://flask.pocoo.org/)
  in order to upload the certificates.
* The client OpenVPN configuration is now possible via the Add-On configuration page.

## Installation

In order to install the Add-On, you currently have to build the Docker container on the system where the Home Assistant
instance is running. 

Therefore, assuming Home Assistant is running at `<server>`, connect to the device using [SSH](https://github.com/hassio-addons/addon-ssh)
  
`ssh <user>@<server>`

and clone this repository in `/addons` with

`cd /addons && git clone https://github.com/larsklitzke/homeassistant-openvpn-client.git`

Enable the `OpenVPNClient` by adding a new `panel_iframe` entity  to your `configuration.yaml` with the following entry:

```yaml
panel_iframe:
  openvpn:
    title: OpenVPN
    icon: mdi:cloud-check
    url: http://<server>:8090


```
with `<server>` as the address of your Home Assistant server.

Restart the Home Assistant instance and afterwards you'll find the `OpenVPN Client` Add-on in the Dashboard where you can configure and start the Add-on. Then, you can visit the OpenVPN website via the `OpenVPN` panel on the left side. There, you can upload the VPN configuration files to connect to your VPN server.

