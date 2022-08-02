# cloudflarewarp
[![codecov](https://codecov.io/gh/BetterCorp/cloudflarewarp/branch/master/graph/badge.svg?token=QFGZS5QJSG)](https://codecov.io/gh/BetterCorp/cloudflarewarp)
[![Go Report Card](https://goreportcard.com/badge/github.com/BetterCorp/cloudflarewarp)](https://goreportcard.com/report/github.com/BetterCorp/cloudflarewarp)
[![Go](https://github.com/BetterCorp/cloudflarewarp/actions/workflows/go.yml/badge.svg)](https://github.com/BetterCorp/cloudflarewarp/actions/workflows/go.yml)

If Traefik is behind a Cloudflare WARP tunnel, it won't be able to get the real IP from the external client as well as other information.

This plugin solves this issue by overwriting the X-Real-IP and X-Forwarded-For with an IP from the CF-Connecting-IP header.  
The real IP will be the Cf-Connecting-IP if request is come from cloudflare ( truest ip in configuration file).  
The plugin also writes the CF-Visitor scheme to the X-Forwarded-Proto. (This fixes an infinite redirect issue for wordpress when using CF[443]->WARP->Traefik[80]->WP[80])  

## Configuration

## Configuration documentation

Supported configurations per body

| Setting| Allowed values | Required | Description |
| :-- | :-- | :-- | :-- |
| trustip | []string | No | IP or IP range to trust |
| disableDefault | bool | Yes | Disable the built in list of CloudFlare IPs/Servers |

### Notes re CloudFlare

One thing included in this plugin is we bundle the CloudFlare server IPs with it, so you do not have to define them manually.  
However on the flip-side, if you want to, you can just disable them by setting `disableDefault` to `true`.  

If you do not define `trustip` and `disableDefault`, it doesn't seem to load the plugin, so just set `disableDefault` to `false` and you are able to use the default IP list.  

### Enable the plugin

```yaml

experimental:
  plugins:
    cloudflarewarp:
      modulename: github.com/BetterCorp/cloudflarewarp
      version: v1.3.0
```  


### Plugin configuration

```yaml
http:  
  middlewares:
    cloudflarewarp:
      plugin:
        cloudflarewarp:
          disableDefault: false
          trustip:
            - "1.1.1.1/24"

  routers:
    my-router:
      rule: Path(`/whoami`)
      service: service-whoami
      entryPoints:
        - http
      middlewares:
        - cloudflarewarp

  services:
   service-whoami:
      loadBalancer:
        servers:
          - url: http://127.0.0.1:5000
```

Code forked and modified from : [https://github.com/vincentinttsh/cloudflareip](https://github.com/vincentinttsh/cloudflareip)