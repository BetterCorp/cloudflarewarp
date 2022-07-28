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
	cfg.TrustIP = []string{"103.21.244.0/22", "172.18.0.1/32", "2405:b500::/32"}

	ctx := context.Background()
	next := http.HandlerFunc(func(rw http.ResponseWriter, req *http.Request) {})
	handler, err := plugin.New(ctx, next, cfg, "cloudflarewarp")
	if err != nil {
		t.Fatal(err)
	}
	testCases := []struct {
		expect500      bool
		trusted        bool
		remote         string
		desc           string
		cfConnectingIP string
		cfVisitor      string
		expected       string
		expectedScheme string
	}{
		{
			remote:         "103.21.244.23",
			desc:           "blank scheme",
			cfConnectingIP: "10.0.0.1",
			cfVisitor:      "",
			expected:       "10.0.0.1",
			expectedScheme: "",
			trusted:        true,
		},
		{
			remote:         "103.21.244.23",
			desc:           "https scheme",
			cfConnectingIP: "10.0.0.1",
			cfVisitor:      "{\"scheme\":\"https\"}",
			expected:       "10.0.0.1",
			expectedScheme: "https",
			trusted:        true,
		},
		{
			remote:         "10.0.1.20",
			desc:           "not trust",
			cfConnectingIP: "127.0.0.2",
			cfVisitor:      "",
			expected:       "",
			expectedScheme: "",
			trusted:        false,
		},
		{
			remote:         "10.0.2",
			desc:           "wrong IP format",
			cfConnectingIP: "10.0.0.1",
			cfVisitor:      "",
			expected:       "",
			expectedScheme: "",
			expect500:      true,
			trusted:        false,
		},
		{
			remote:         "10.0.300.20",
			desc:           "wrong IP address",
			cfConnectingIP: "10.0.0.1",
			cfVisitor:      "",
			expected:       "",
			expectedScheme: "",
			expect500:      true,
			trusted:        false,
		},
		{
			remote:         "103.21.244.23",
			desc:           "forward",
			cfConnectingIP: "10.0.0.1",
			cfVisitor:      "",
			expected:       "10.0.0.1",
			expectedScheme: "",
			trusted:        true,
		},
		{
			remote:         "172.18.0.1",
			desc:           "forward",
			cfConnectingIP: "10.0.0.1",
			cfVisitor:      "",
			expected:       "10.0.0.1",
			expectedScheme: "",
			trusted:        true,
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
			req.Header.Set("X-Real-Ip", test.remote)
			req.Header.Set("Cf-Connecting-IP", test.cfConnectingIP)
			req.Header.Set("Cf-Visitor", test.cfVisitor)

			handler.ServeHTTP(recorder, req)

			if recorder.Result().StatusCode == 500 {
				if test.expect500 == true {
					return
				}
				t.Errorf("invalid response: 500")
				return
			}

			if test.trusted {
				assertHeader(t, req, "X-Is-Trusted", "yes")
				assertHeader(t, req, "X-Real-Ip", test.expected)
			} else {
				assertHeader(t, req, "X-Is-Trusted", "no")
				assertHeader(t, req, "X-Real-Ip", test.remote)
			}
			assertHeader(t, req, "X-Forwarded-For", test.expected)
			assertHeader(t, req, "X-Forwarded-Proto", test.expectedScheme)
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
		t.Errorf("invalid header(%s) value: %s", key, req.Header.Get(key))
	}
}
