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
| trustip | []string | Yes | IP or IP range to trust |

### Static

```yaml
pilot:
  token: xxxx

experimental:
  plugins:
    traefik-cf-warp:
      modulename: github.com/BetterCorp/cloudflarewarp
      version: v1.0.0
```
### Dynamic configuration

```yaml
http:
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
  
  middlewares:
    cloudflarewarp:
      plugin:
        cloudflarewarp:
          trustip:
            - "1.1.1.1/24"
```

Code forked and modified from : [https://github.com/vincentinttsh/cloudflareip](https://github.com/vincentinttsh/cloudflareip)