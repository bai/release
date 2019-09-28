package main

import (
	"reflect"
	"strings"
	"testing"
)

func TestGetKubeadmDependencies(t *testing.T) {
	testcases := []struct {
		name    string
		version string
		deps    []string
	}{
		{
			name:    "minimum supported kubernetes",
			version: "1.13.0",
			deps: []string{
				"kubelet (>= 1.13.0)",
				"kubectl (>= 1.13.0)",
				"kubernetes-cni (>= 0.7.5)",
				"cri-tools (>= 1.13.0)",
				"${misc:Depends}",
			},
		},
		{
			name:    "latest stable minor kubernetes",
			version: "1.16.0",
			deps: []string{
				"kubelet (>= 1.13.0)",
				"kubectl (>= 1.13.0)",
				"kubernetes-cni (>= 0.7.5)",
				"cri-tools (>= 1.13.0)",
				"${misc:Depends}",
			},
		},
		{
			name:    "latest alpha kubernetes",
			version: "1.17.0-alpha.0",
			deps: []string{
				"kubelet (>= 1.13.0)",
				"kubectl (>= 1.13.0)",
				"kubernetes-cni (>= 0.7.5)",
				"cri-tools (>= 1.13.0)",
				"${misc:Depends}",
			},
		},
		{
			name:    "next stable minor kubernetes",
			version: "1.17.0",
			deps: []string{
				"kubelet (>= 1.13.0)",
				"kubectl (>= 1.13.0)",
				"kubernetes-cni (>= 0.7.5)",
				"cri-tools (>= 1.13.0)",
				"${misc:Depends}",
			},
		},
	}

	for _, tc := range testcases {
		t.Run(tc.name, func(t *testing.T) {
			packageDef := packageDefinition{Version: tc.version}
			deps, err := getKubeadmDependencies(packageDef)
			if err != nil {
				t.Fatalf("did not expect an error: %v", err)
			}
			actual := strings.Split(deps, ", ")
			if len(actual) != len(tc.deps) {
				t.Fatalf("Expected %d deps but found %d", len(tc.deps), len(actual))
			}
			if !reflect.DeepEqual(actual, tc.deps) {
				t.Fatalf("expected %q but got %q", tc.deps, actual)
			}
		})
	}

}
