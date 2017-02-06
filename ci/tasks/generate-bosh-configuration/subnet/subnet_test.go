package subnet_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"github.com/pivotal-cf/pcf-releng-ci/tasks/om/generate-bosh-configuration/subnet"
)

var _ = Describe("Subnet", func() {
	Describe("ParseSubnet", func() {
		It("parses the subnet", func() {
			s, err := subnet.ParseSubnet("10.0.0.0/24")
			Expect(err).NotTo(HaveOccurred())
			Expect(s).To(Equal(subnet.Subnet{
				Octets: [4]int{10, 0, 0, 0},
				Mask:   24,
			}))
		})

		Context("failure cases", func() {
			Context("when the subnet does not have a mask", func() {
				It("returns an error", func() {
					_, err := subnet.ParseSubnet("10.0.0.0/3/1")
					Expect(err).To(MatchError("subnet \"10.0.0.0/3/1\" could not be parsed"))
				})
			})

			Context("when the subnet mask cannot be parsed", func() {
				It("returns an error", func() {
					_, err := subnet.ParseSubnet("10.0.0.0/banana")
					Expect(err).To(MatchError(ContainSubstring("subnet mask \"banana\" could not be parsed")))
				})
			})

			Context("when the subnet octets cannot be parsed", func() {
				It("returns an error", func() {
					_, err := subnet.ParseSubnet("10.0/24")
					Expect(err).To(MatchError("subnet octets \"10.0\" could not be parsed"))
				})
			})

			Context("when the subnet octets contain an invalid octet", func() {
				It("returns an error", func() {
					_, err := subnet.ParseSubnet("10.0.banana.0/24")
					Expect(err).To(MatchError(ContainSubstring("subnet octet \"banana\" could not be parsed")))
				})
			})
		})
	})

	Describe("Range", func() {
		var s subnet.Subnet

		BeforeEach(func() {
			var err error
			s, err = subnet.ParseSubnet("10.0.0.0/24")
			Expect(err).NotTo(HaveOccurred())
		})

		It("returns a range of the subnet", func() {
			r, err := s.Range(0, 10)
			Expect(err).NotTo(HaveOccurred())
			Expect(r).To(Equal("10.0.0.0-10.0.0.10"))
		})

		Context("failure cases", func() {
			Context("when the start value is negative", func() {
				It("returns an error", func() {
					_, err := s.Range(-1, 10)
					Expect(err).To(MatchError("subnet range start \"-1\" cannot be negative"))
				})
			})

			Context("when the end value is greater than 256", func() {
				It("returns an error", func() {
					_, err := s.Range(1, 258)
					Expect(err).To(MatchError("subnet range end \"258\" cannot exceed 256"))
				})
			})

			Context("when the start value is greater than the end value", func() {
				It("returns an error", func() {
					_, err := s.Range(250, 245)
					Expect(err).To(MatchError("subnet range start \"250\" cannot exceed subnet range end \"245\""))
				})
			})
		})
	})
})
