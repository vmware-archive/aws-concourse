package subnet_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"testing"
)

func TestSubnet(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Subnet Suite")
}
