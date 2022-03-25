package cloudflarewarp

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
)

const (
	xRealIP        = "X-Real-IP"
	xForwardFor    = "X-Forwarded-For"
	xForwardProto  = "X-Forwarded-Proto"
	cfConnectingIP = "CF-Connecting-IP"
	cfVisitor      = "CF-Visitor"
)

// Config the plugin configuration.
type Config struct {
	TrustIP []string `json:"trustip,omitempty" toml:"trustip,omitempty" yaml:"trustip,omitempty"`
}

// CreateConfig creates the default plugin configuration.
func CreateConfig() *Config {
	return &Config{
		TrustIP: []string{},
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

	return ipOverWriter, nil
}

func (r *RealIPOverWriter) ServeHTTP(rw http.ResponseWriter, req *http.Request) {
	if r.trust(req.RemoteAddr) {
		req.Header.Set(xRealIP, req.Header.Get(cfConnectingIP))
		req.Header.Set(xForwardFor, req.Header.Get(cfConnectingIP))
		if req.Header.Get(cfVisitor) != "" {
			var cfVisitorValue CFVisitorHeader
			json.Unmarshal([]byte(req.Header.Get(cfVisitor)), &cfVisitorValue)
			req.Header.Set(xForwardProto, cfVisitorValue.Scheme)
		}
	}
	r.next.ServeHTTP(rw, req)
}

func (r *RealIPOverWriter) trust(s string) bool {
	temp, _, err := net.SplitHostPort(s)
	if err != nil {
		return false
	}
	ip := net.ParseIP(temp)
	for _, network := range r.TrustIP {
		if network.Contains(ip) {
			return true
		}
	}
	return false
}
