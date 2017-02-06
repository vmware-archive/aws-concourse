package main_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"github.com/onsi/gomega/gexec"

	"testing"
)

func TestGenerateBoshConfiguration(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "GenerateBoshConfiguration Suite")
}

var pathToMain string

var _ = BeforeSuite(func() {
	var err error
	pathToMain, err = gexec.Build("github.com/c0-ops/aws-concourse/ci/tasks/generate-bosh-configuration")
	Expect(err).NotTo(HaveOccurred())
})

var _ = AfterSuite(func() {
	gexec.CleanupBuildArtifacts()
})
