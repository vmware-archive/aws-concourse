package main_test

import (
	"os/exec"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"github.com/onsi/gomega/gbytes"
	"github.com/onsi/gomega/gexec"
)

var _ = Describe("generate-bosh-configuration", func() {
	var providerConfiguration string

	Context("when the provider is GCP", func() {
		BeforeEach(func() {
			providerConfiguration = `{
				"azs": ["us-central1-a", "us-central1-b"],
				"network_name": "vine-whale-pcf-network",
				"ops_manager_cidr": "10.0.0.0/24",
				"ops_manager_subnet": "vine-whale-om-subnet",
				"ops_manager_gateway": "10.0.0.1",
				"ert_cidr": "10.0.1.0/24",
				"ert_subnet": "vine-whale-ert-subnet",
				"ert_gateway": "10.0.1.1",
				"services_cidr": "10.0.2.0/24",
				"services_subnet": "vine-whale-services-subnet",
				"services_gateway": "10.0.2.1",
				"project": "cf-release-engineering",
				"region": "us-central1",
				"service_account_key": "foo"
			}`
		})

		It("outputs a configuration JSON for bosh", func() {
			command := exec.Command(pathToMain,
				"--provider", "gcp",
				"--provider-configuration", providerConfiguration,
				"--env-name", "vine-whale",
			)
			session, err := gexec.Start(command, GinkgoWriter, GinkgoWriter)
			Expect(err).NotTo(HaveOccurred())
			Eventually(session).Should(gexec.Exit(0))
			Expect(session.Out.Contents()).To(MatchJSON(`{
				"az_configuration": {
					"availability_zones": [
						{ "name": "us-central1-a" },
						{ "name": "us-central1-b" }
					]
			  },
				"iaas_configuration": {
					"project": "cf-release-engineering",
					"default_deployment_tag": "vine-whale-vms",
					"auth_json": "foo"
				},
				"director_configuration": {
				  "ntp_servers_string": "169.254.169.254"
				},
				"networks_configuration": {
					"icmp_checks_enabled": false,
					"networks": [
						{
							"name": "vine-whale-om-subnet",
							"service_network": false,
							"iaas_identifier": "vine-whale-pcf-network/vine-whale-om-subnet/us-central1",
							"subnets": [
								{
									"cidr": "10.0.0.0/24",
									"reserved_ip_ranges": "10.0.0.0-10.0.0.4",
									"dns": "8.8.8.8",
									"gateway": "10.0.0.1",
									"availability_zones": [ "us-central1-a","us-central1-b" ]
								}
							]
						},
						{
							"name": "vine-whale-ert-subnet",
							"service_network": false,
							"iaas_identifier": "vine-whale-pcf-network/vine-whale-ert-subnet/us-central1",
							"subnets": [
								{
									"cidr": "10.0.1.0/24",
									"reserved_ip_ranges": "10.0.1.0-10.0.1.4",
									"dns": "8.8.8.8",
									"gateway": "10.0.1.1",
									"availability_zones": [ "us-central1-a","us-central1-b" ]
								}
							]
						},
						{
							"name": "vine-whale-services-subnet",
							"service_network": true,
							"iaas_identifier": "vine-whale-pcf-network/vine-whale-services-subnet/us-central1",
							"subnets": [
								{
									"cidr": "10.0.2.0/24",
									"reserved_ip_ranges": "10.0.2.0-10.0.2.3",
									"dns": "8.8.8.8",
									"gateway": "10.0.2.1",
									"availability_zones": [ "us-central1-a","us-central1-b" ]
								}
							]
						}
					]
				},
				"network_assignment": {
					"singleton_availability_zone": "us-central1-a",
					"network": "vine-whale-om-subnet"
			  }
			}`))
		})
	})

	/*
		Context("when the provider is AWS", func() {
			BeforeEach(func() {
				providerConfiguration = `{
					"azs": ["az1", "az2"],
					"director_subnet_availability_zones": "az1,az2",
					"director_subnet_cidrs": "director-cidr-1,director-cidr-2",
					"director_subnet_ids": "director-subnet-1,director-subnet-2",
					"ert_subnet_availability_zones": "az1,az2",
					"ert_subnet_cidrs": "ert-cidr-1,ert-cidr-2",
					"ert_subnet_ids": "ert-subnet-1,ert-subnet-2",
					"ops_manager_private_key": "fake-private-key",
					"ops_manager_public_key_name": "fake-public-key-name",
					"region": "fake-region",
					"service_subnet_availability_zones": "az1,az2",
					"service_subnet_cidrs": "service-cidr-1,service-cidr-2",
					"service_subnet_ids": "service-subnet-1,service-subnet-2",
					"vms_security_group_id": "fake-security-group-id",
					"vpc_id": "fake-vpc-id"
				}`
			})

			It("outputs a configuration JSON for bosh", func() {
				command := exec.Command(pathToMain,
					"--provider", "aws",
					"--provider-configuration", providerConfiguration,
					"--env-name", "vine-whale",
					"--aws-access-key-id", "access-key-id",
					"--aws-secret-access-key", "secret-access-key",
				)
				session, err := gexec.Start(command, GinkgoWriter, GinkgoWriter)
				Expect(err).NotTo(HaveOccurred())
				Eventually(session).Should(gexec.Exit(0))
				Expect(session.Out.Contents()).To(MatchJSON(`{
					"iaas_configuration": {
						"access_key_id": "access-key-id",
						"secret_access_key": "secret-access-key",
						"vpc_id": "fake-vpc-id",
						"security_group": "fake-security-group-id",
						"key_pair_name": "fake-public-key-name",
						"ssh_private_key": "fake-private-key",
						"region": "fake-region",
						"encrypted": false
					},
					"director_configuration": {
					  "ntp_servers_string": "169.254.169.254"
					},
					"az_configuration": {
						"availability_zones": [
							{ "name": "az1" },
							{ "name": "az2" }
						]
				  },
					"networks_configuration": {
						"icmp_checks_enabled": false,
						"networks": [
							{
								"name": "vine-whale-director-subnet",
								"service_network": false,
								"subnets": [
									{
										"iaas_identifier": "director-subnet-1",
										"cidr": "",
										"reserved_ip_ranges": "",
										"dns": "8.8.8.8",
										"gateway": "",
										"availability_zone_references": [ "az1" ]
									},
									{
										"iaas_identifier": "director-subnet-2",
										"cidr": "",
										"reserved_ip_ranges": "",
										"dns": "8.8.8.8",
										"gateway": "",
										"availability_zone_references": [ "az2" ]
									}
								]
							},
							{
								"name": "vine-whale-ert-subnet",
								"service_network": false,
								"subnets": [
									{
										"iaas_identifier": "ert-subnet-1",
										"cidr": "",
										"reserved_ip_ranges": "",
										"dns": "8.8.8.8",
										"gateway": "",
										"availability_zone_references": [ "az1" ]
									},
									{
										"iaas_identifier": "ert-subnet-2",
										"cidr": "",
										"reserved_ip_ranges": "",
										"dns": "8.8.8.8",
										"gateway": "",
										"availability_zone_references": [ "az2" ]
									}
								]
							},
							{
								"name": "vine-whale-services-subnet",
								"service_network": true,
								"subnets": [
									{
										"iaas_identifier": "service-subnet-1",
										"cidr": "",
										"reserved_ip_ranges": "",
										"dns": "8.8.8.8",
										"gateway": "",
										"availability_zone_references": [ "az1" ]
									},
									{
										"iaas_identifier": "service-subnet-2",
										"cidr": "",
										"reserved_ip_ranges": "",
										"dns": "8.8.8.8",
										"gateway": "",
										"availability_zone_references": [ "az2" ]
									}
								]
							}
						]
					},
					"network_assignment": {
						"singleton_availability_zone": "az1",
						"network": "vine-whale-director-subnet"
				  }
				}`))
			})
		})
	*/

	Context("when the provider is Azure", func() {
		BeforeEach(func() {
			providerConfiguration = `{
					"bosh_root_storage_account": "bosh-storage-account",
					"wildcard_vm_storage_account": "bosh-vms-account",
					"client_id": "some-client-id",
					"client_secret": "some-client-secret",
					"env_dns_zone_name_servers": [
						"ns1-07.azure-dns.com.",
						"ns3-07.azure-dns.org.",
						"ns2-07.azure-dns.net.",
						"ns4-07.azure-dns.info."
					],
					"ops_manager_dns": "pcf.navy-spur.azure.releng.cf-app.com",
					"ops_manager_public_ip": "111.111.111.111",
					"ops_manager_security_group_name": "navy-spur-ops-manager-security-group",
					"ops_manager_ssh_private_key": "---SOME PRIVATE KEY---",
					"ops_manager_ssh_public_key": "ssh-rsa some-public-key",
					"ops_manager_storage_account": "ops-manager-account",
					"pcf_resource_group_name": "navy-spur-pcf-resource-group",
					"ops_manager_cidr": "10.0.0.0/24",
					"ops_manager_subnet": "navy-spur-om-subnet",
					"ops_manager_gateway": "om-gateway",
					"ert_cidr": "10.0.1.0/24",
					"ert_subnet": "navy-spur-ert-subnet",
					"ert_gateway": "ert-gateway",
					"services_cidr": "10.0.2.0/24",
					"services_subnet": "navy-spur-services-subnet",
					"services_gateway": "services-gateway",
					"network_name": "navy-spur-virtual-network",
					"subscription_id": "some-subscription-id",
					"tenant_id": "some-tenant-id"
			}`
		})

		It("outputs a configuration JSON for bosh", func() {
			command := exec.Command(pathToMain,
				"--provider", "azure",
				"--provider-configuration", providerConfiguration,
				"--env-name", "navy-spur",
			)
			session, err := gexec.Start(command, GinkgoWriter, GinkgoWriter)
			Expect(err).NotTo(HaveOccurred())
			Eventually(session).Should(gexec.Exit(0))
			Expect(session.Out.Contents()).To(MatchJSON(`{
					"iaas_configuration": {
						"subscription_id": "some-subscription-id",
						"tenant_id": "some-tenant-id",
						"client_id": "some-client-id",
						"client_secret": "some-client-secret",
						"resource_group_name": "navy-spur-pcf-resource-group",
						"bosh_storage_account_name": "bosh-storage-account",
						"default_security_group": "navy-spur-ops-manager-security-group",
						"ssh_public_key": "ssh-rsa some-public-key",
						"ssh_private_key": "---SOME PRIVATE KEY---",
						"deployments_storage_account_name": "bosh-vms-account"
					},
					"director_configuration": {
						"ntp_servers_string": "us.pool.ntp.org"
					},
					"networks_configuration": {
						"icmp_checks_enabled": false,
						"networks": [
							{
								"name": "navy-spur-om-subnet",
								"service_network": false,
								"iaas_identifier": "navy-spur-virtual-network/navy-spur-om-subnet",
								"subnets": [
									{
										"cidr": "10.0.0.0/24",
										"reserved_ip_ranges": "10.0.0.0-10.0.0.5",
										"dns": "8.8.8.8",
										"gateway": "om-gateway"
									}
								]
							},
							{
								"name": "navy-spur-ert-subnet",
								"service_network": false,
								"iaas_identifier": "navy-spur-virtual-network/navy-spur-ert-subnet",
								"subnets": [
									{
										"cidr": "10.0.1.0/24",
										"reserved_ip_ranges": "10.0.1.0-10.0.1.4",
										"dns": "8.8.8.8",
										"gateway": "ert-gateway"
									}
								]
							},
							{
								"name": "navy-spur-services-subnet",
								"service_network": true,
								"iaas_identifier": "navy-spur-virtual-network/navy-spur-services-subnet",
								"subnets": [
									{
										"cidr": "10.0.2.0/24",
										"reserved_ip_ranges": "10.0.2.0-10.0.2.3",
										"dns": "8.8.8.8",
										"gateway": "services-gateway"
									}
								]
							}
						]
					},
					"network_assignment": {
						"network": "navy-spur-om-subnet"
					}
				}`))
		})
	})

	Context("when the provider is vSphere", func() {
		BeforeEach(func() {
			providerConfiguration = `{
				"azs": ["us-central1-a", "us-central1-b"],
				"clusters": ["cluster-1", "cluster-2"],
				"resource_pools": ["pool-1", "pool-2"],
				"network_name": "vine-whale-pcf-network",
				"ops_manager_cidr": "10.0.0.0/24",
				"ops_manager_subnet": "vine-whale-om-subnet",
				"ops_manager_gateway": "10.0.0.1",
				"ert_cidr": "10.0.1.0/24",
				"ert_subnet": "vine-whale-ert-subnet",
				"ert_gateway": "10.0.1.1",
				"services_cidr": "10.0.2.0/24",
				"services_subnet": "vine-whale-services-subnet",
				"services_gateway": "10.0.2.1",
				"project": "cf-release-engineering",
				"region": "us-central1",
				"service_account_key": "foo"
			}`
		})

		It("outputs a configuration JSON for bosh", func() {
			command := exec.Command(pathToMain,
				"--provider", "vsphere",
				"--provider-configuration", providerConfiguration,
				"--env-name", "vine-whale",
			)
			session, err := gexec.Start(command, GinkgoWriter, GinkgoWriter)
			Expect(err).NotTo(HaveOccurred())
			Eventually(session).Should(gexec.Exit(0))
			Expect(session.Out.Contents()).To(MatchJSON(`{
				"az_configuration": {
					"availability_zones": [
						{
							"name": "us-central1-a",
							"cluster": "cluster-1",
							"resource_pool": "pool-1"
						},
						{
							"name": "us-central1-b",
							"cluster": "cluster-2",
							"resource_pool": "pool-2"
					  }
					]
			  },
				"iaas_configuration": {
					"project": "cf-release-engineering",
					"default_deployment_tag": "vine-whale-vms",
					"auth_json": "foo"
				},
				"director_configuration": {
				  "ntp_servers_string": "169.254.169.254"
				},
				"networks_configuration": {
					"icmp_checks_enabled": false,
					"networks": [
						{
							"name": "vine-whale-om-subnet",
							"service_network": false,
							"iaas_identifier": "vine-whale-pcf-network/vine-whale-om-subnet/us-central1",
							"subnets": [
								{
									"cidr": "10.0.0.0/24",
									"reserved_ip_ranges": "10.0.0.0-10.0.0.4",
									"dns": "8.8.8.8",
									"gateway": "10.0.0.1",
									"availability_zones": [ "us-central1-a","us-central1-b" ]
								}
							]
						},
						{
							"name": "vine-whale-ert-subnet",
							"service_network": false,
							"iaas_identifier": "vine-whale-pcf-network/vine-whale-ert-subnet/us-central1",
							"subnets": [
								{
									"cidr": "10.0.1.0/24",
									"reserved_ip_ranges": "10.0.1.0-10.0.1.4",
									"dns": "8.8.8.8",
									"gateway": "10.0.1.1",
									"availability_zones": [ "us-central1-a","us-central1-b" ]
								}
							]
						},
						{
							"name": "vine-whale-services-subnet",
							"service_network": true,
							"iaas_identifier": "vine-whale-pcf-network/vine-whale-services-subnet/us-central1",
							"subnets": [
								{
									"cidr": "10.0.2.0/24",
									"reserved_ip_ranges": "10.0.2.0-10.0.2.3",
									"dns": "8.8.8.8",
									"gateway": "10.0.2.1",
									"availability_zones": [ "us-central1-a","us-central1-b" ]
								}
							]
						}
					]
				},
				"network_assignment": {
					"singleton_availability_zone": "us-central1-a",
					"network": "vine-whale-om-subnet"
			  }
			}`))
		})
	})

	Context("error cases", func() {
		Context("when an invalid provider is specified", func() {
			It("throws an error", func() {
				command := exec.Command(pathToMain,
					"--provider", "foo",
				)
				session, err := gexec.Start(command, GinkgoWriter, GinkgoWriter)
				Expect(err).NotTo(HaveOccurred())
				Eventually(session).Should(gexec.Exit(1))
				Eventually(session.Err).Should(gbytes.Say("invalid provider: foo"))
			})
		})

		Context("when provided invalid json in the provider configuration", func() {
			It("throws an error", func() {
				command := exec.Command(pathToMain,
					"--provider", "gcp",
					"--provider-configuration", "%%%",
					"--env-name", "vine-whale",
				)
				session, err := gexec.Start(command, GinkgoWriter, GinkgoWriter)
				Expect(err).NotTo(HaveOccurred())
				Eventually(session).Should(gexec.Exit(1))
				Eventually(session.Err).Should(gbytes.Say("invalid character"))
			})
		})

		Context("when provided an invalid subnet CIDR", func() {
			It("throws an error", func() {
				providerConfiguration = `{
					"azs": ["us-central1-a", "us-central1-b"],
					"network_name": "vine-whale-pcf-network",
					"ops_manager_cidr": "om-cidr",
					"ops_manager_subnet": "vine-whale-om-subnet",
					"ops_manager_gateway": "10.0.0.1",
					"ert_cidr": "10.0.1.0/24",
					"ert_subnet": "vine-whale-ert-subnet",
					"ert_gateway": "10.0.1.1",
					"services_cidr": "10.0.2.0/24",
					"services_subnet": "vine-whale-services-subnet",
					"services_gateway": "10.0.2.1",
					"project": "cf-release-engineering",
					"region": "us-central1",
					"service_account_key": "foo"
				}`
				command := exec.Command(pathToMain,
					"--provider", "gcp",
					"--provider-configuration", providerConfiguration,
					"--env-name", "vine-whale",
				)
				session, err := gexec.Start(command, GinkgoWriter, GinkgoWriter)
				Expect(err).NotTo(HaveOccurred())
				Eventually(session).Should(gexec.Exit(1))
				Eventually(session.Err).Should(gbytes.Say(`subnet "om-cidr" could not be parsed`))
			})
		})
	})
})
