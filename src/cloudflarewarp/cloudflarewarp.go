package cloudflarewarp

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"strings"

	"github.com/BetterCorp/cloudflarewarp/src/ips"
)

const (
	xRealIP        = "X-Real-IP"
	xCfTrusted     = "X-Is-Trusted"
	xForwardFor    = "X-Forwarded-For"
	xForwardProto  = "X-Forwarded-Proto"
	cfConnectingIP = "CF-Connecting-IP"
	cfVisitor      = "CF-Visitor"
)

// Config the plugin configuration.
type Config struct {
	TrustIP             []string `json:"trustip,omitempty"`
	DisableDefaultCFIPs bool
}
type TrustResult struct {
	isError  bool
	trusted  bool
	directIP string
}

// CreateConfig creates the default plugin configuration.
func CreateConfig() *Config {
	return &Config{
		TrustIP:             []string{},
		DisableDefaultCFIPs: false,
	}
}

// RealIPOverWriter is a plugin that overwrite true IP.
type RealIPOverWriter struct {
	next    http.Handler
	name    string
	TrustIP []*net.IPNet
}

// CFVisitorHeader definition for the header value
type CFVisitorHeader struct {
	Scheme string `json:"scheme"`
}

// New created a new plugin.
func New(ctx context.Context, next http.Handler, config *Config, name string) (http.Handler, error) {
	ipOverWriter := &RealIPOverWriter{
		next: next,
		name: name,
	}

	for _, v := range config.TrustIP {
		_, trustip, err := net.ParseCIDR(v)
		if err != nil {
			return nil, err
		}

		ipOverWriter.TrustIP = append(ipOverWriter.TrustIP, trustip)
	}

	if config.DisableDefaultCFIPs != true {
		for _, v := range ips.CFIPs() {
			_, trustip, err := net.ParseCIDR(v)
			if err != nil {
				return nil, err
			}

			ipOverWriter.TrustIP = append(ipOverWriter.TrustIP, trustip)
		}
	}

	return ipOverWriter, nil
}

func (r *RealIPOverWriter) ServeHTTP(rw http.ResponseWriter, req *http.Request) {
	req.Header.Del(xCfTrusted)
	req.Header.Del(xForwardFor)
	req.Header.Del(xRealIP)
	req.Header.Del(xForwardProto)

	trustResult := r.trust(req.RemoteAddr)
	if trustResult.directIP == "" || trustResult.isError {
		http.Error(rw, "Unknown source", 500)
		return
	}
	if trustResult.trusted {
		req.Header.Set(xCfTrusted, "yes")
		req.Header.Set(xForwardFor, strings.Split(req.Header.Get(cfConnectingIP), ",")[0])
		if req.Header.Get(cfVisitor) != "" {
			var cfVisitorValue CFVisitorHeader
			json.Unmarshal([]byte(req.Header.Get(cfVisitor)), &cfVisitorValue)
			req.Header.Set(xForwardProto, cfVisitorValue.Scheme)
		}
	} else {
		req.Header.Set(xCfTrusted, "no")
		req.Header.Del(cfVisitor)
		req.Header.Del(cfConnectingIP)
	}
	req.Header.Set(xRealIP, trustResult.directIP)
	r.next.ServeHTTP(rw, req)
}

func (r *RealIPOverWriter) trust(s string) *TrustResult {
	temp, _, err := net.SplitHostPort(s)
	if err != nil {
		return &TrustResult{
			isError:  true,
			trusted:  false,
			directIP: "",
		}
	}
	ip := net.ParseIP(temp)
	if ip == nil {
		return &TrustResult{
			isError:  true,
			trusted:  false,
			directIP: "",
		}
	}
	for _, network := range r.TrustIP {
		if network.Contains(ip) {
			return &TrustResult{
				isError:  false,
				trusted:  true,
				directIP: ip.String(),
			}
		}
	}
	return &TrustResult{
		isError:  false,
		trusted:  false,
		directIP: ip.String(),
	}
}
