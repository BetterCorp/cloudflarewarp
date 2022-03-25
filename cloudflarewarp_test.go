package cloudflarewarp_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	plugin "github.com/BetterCorp/cloudflarewarp"
)

func TestNew(t *testing.T) {
	cfg := plugin.CreateConfig()
	cfg.TrustIP = []string{"103.21.244.0/22", "172.18.0.1"}

	ctx := context.Background()
	next := http.HandlerFunc(func(rw http.ResponseWriter, req *http.Request) {})
	handler, err := plugin.New(ctx, next, cfg, "cloudflarewarp")
	if err != nil {
		t.Fatal(err)
	}
	testCases := []struct {
		remote         string
		desc           string
		cfConnectingIP string
		expected       string
	}{
		{
			remote:         "10.0.1.20",
			desc:           "not trust",
			cfConnectingIP: "127.0.0.2",
			expected:       "",
		},
		{
			remote:         "10.0.2",
			desc:           "wrong IP format",
			cfConnectingIP: "10.0.0.1",
			expected:       "",
		},
		{
			remote:         "10.0.300.20",
			desc:           "wrong IP address",
			cfConnectingIP: "10.0.0.1",
			expected:       "",
		},
		{
			remote:         "103.21.244.23",
			desc:           "forward",
			cfConnectingIP: "10.0.0.1",
			expected:       "10.0.0.1",
		},
		{
			remote:         "172.18.0.1",
			desc:           "forward",
			cfConnectingIP: "10.0.0.1",
			expected:       "10.0.0.1",
		},
	}
	for _, test := range testCases {
		test := test
		t.Run(test.desc, func(t *testing.T) {
			recorder := httptest.NewRecorder()

			req, err := http.NewRequestWithContext(ctx, http.MethodGet, "http://localhost", nil)
			if err != nil {
				t.Fatal(err)
			}
			req.RemoteAddr = test.remote + ":36001"
			req.Header.Set("Cf-Connecting-IP", test.cfConnectingIP)

			handler.ServeHTTP(recorder, req)

			assertHeader(t, req, "X-Real-Ip", test.expected)
		})
	}
}

func TestError(t *testing.T) {
	cfg := plugin.CreateConfig()
	cfg.TrustIP = []string{"103.21.244.0"}

	ctx := context.Background()
	next := http.HandlerFunc(func(rw http.ResponseWriter, req *http.Request) {})
	_, err := plugin.New(ctx, next, cfg, "cloudflarewarp")
	if err == nil {
		t.Fatalf("expected error, got none")
	}
}
func assertHeader(t *testing.T, req *http.Request, key, expected string) {
	t.Helper()

	if req.Header.Get(key) != expected {
		t.Errorf("invalid header value: %s", req.Header.Get(key))
	}
}
