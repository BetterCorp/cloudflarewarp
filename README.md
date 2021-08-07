# cloudflareip
[![codecov](https://codecov.io/gh/vincentinttsh/cloudflareip/branch/master/graph/badge.svg?token=QFGZS5QJSG)](https://codecov.io/gh/vincentinttsh/cloudflareip)
[![Go Report Card](https://goreportcard.com/badge/github.com/vincentinttsh/cloudflareip)](https://goreportcard.com/report/github.com/vincentinttsh/cloudflareip)

If Traefik is behind Cloudflare, it won't be able to get the real IP from the external client by checking the remote IP address.

This plugin solves this issue by overwriting the X-Real-IP with an IP from the Cf-Connecting-IP header. The real IP will be the Cf-Connecting-IP if request is come from cloudflare ( truest ip in configuration file).

## Configuration

## Configuration documentation

Supported configurations per body

| Setting| Allowed values | Required | Description |
| :-- | :-- | :-- | :-- |
| trustip | []string | Yes | IP or IP range to exclude forward IP |

### Static

```yaml
pilot:
  token: xxxx

experimental:
  plugins:
    traefik-real-ip:
      modulename: github.com/vincentinttsh/cloudflareip
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
        - cloudflareip

  services:
   service-whoami:
      loadBalancer:
        servers:
          - url: http://127.0.0.1:5000
  
  middlewares:
    cloudflareip:
      plugin:
        cloudflareip:
          trustip:
            - "1.1.1.1/24"
```
