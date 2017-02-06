package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"

	"github.com/Jeffail/gabs"
	"github.com/aditya87/hummus"
	"github.com/pivotal-cf/pcf-releng-ci/tasks/om/generate-bosh-configuration/subnet"
)

var (
	provider              string
	providerConfiguration string
	envName               string
	awsAccessKeyID        string
	awsSecretAccessKey    string
)

type Config struct {
	/**IaaS configuration**/
	//GCP
	Project              string `json:"project" hummus:"iaas_configuration.project,omitempty"`
	DefaultDeploymentTag string `hummus:"iaas_configuration.default_deployment_tag,omitempty"`
	AuthJSON             string `json:"service_account_key" hummus:"iaas_configuration.auth_json,omitempty"`

	//Azure
	SubscriptionID                string `json:"subscription_id" hummus:"iaas_configuration.subscription_id,omitempty"`
	TenantID                      string `json:"tenant_id" hummus:"iaas_configuration.tenant_id,omitempty"`
	ClientID                      string `json:"client_id" hummus:"iaas_configuration.client_id,omitempty"`
	ClientSecret                  string `json:"client_secret" hummus:"iaas_configuration.client_secret,omitempty"`
	ResourceGroupName             string `json:"pcf_resource_group_name" hummus:"iaas_configuration.resource_group_name,omitempty"`
	BoshStorageAccountName        string `json:"bosh_root_storage_account" hummus:"iaas_configuration.bosh_storage_account_name,omitempty"`
	DefaultSecurityGroup          string `json:"ops_manager_security_group_name" hummus:"iaas_configuration.default_security_group,omitempty"`
	SSHPublicKey                  string `json:"ops_manager_ssh_public_key" hummus:"iaas_configuration.ssh_public_key,omitempty"`
	SSHPrivateKey                 string `json:"ops_manager_ssh_private_key" hummus:"iaas_configuration.ssh_private_key,omitempty"`
	DeploymentsStorageAccountName string `json:"wildcard_vm_storage_account" hummus:"iaas_configuration.deployments_storage_account_name,omitempty"`

	/**Director configuration**/
	NTPServers string `hummus:"director_configuration.ntp_servers_string,omitempty"`

	/**AZ configuration**/
	AZs           []string `json:"azs"`
	Clusters      []string `json:"clusters"`
	ResourcePools []string `json:"resource_pools"`

	/**Networks configuration**/
	Region  string `json:"region"`
	Network string `json:"network_name"`

	ICMPChecksEnabled bool `hummus:"networks_configuration.icmp_checks_enabled"`

	OpsmanNetworkName    string   `json:"ops_manager_subnet" hummus:"networks_configuration.networks[0].name,omitempty"`
	OpsmanServiceNetwork bool     `hummus:"networks_configuration.networks[0].service_network"`
	OpsmanIaasIdentifier string   `hummus:"networks_configuration.networks[0].iaas_identifier,omitempty"`
	OpsmanCIDR           string   `json:"ops_manager_cidr" hummus:"networks_configuration.networks[0].subnets[0].cidr,omitempty"`
	OpsmanReservedIPs    string   `hummus:"networks_configuration.networks[0].subnets[0].reserved_ip_ranges,omitempty"`
	OpsmanSubnetDNS      string   `hummus:"networks_configuration.networks[0].subnets[0].dns,omitempty"`
	OpsmanGateway        string   `json:"ops_manager_gateway" hummus:"networks_configuration.networks[0].subnets[0].gateway,omitempty"`
	OpsmanAZs            []string `hummus:"networks_configuration.networks[0].subnets[0].availability_zones,omitempty"`

	ERTNetworkName    string   `json:"ert_subnet" hummus:"networks_configuration.networks[1].name,omitempty"`
	ERTServiceNetwork bool     `hummus:"networks_configuration.networks[1].service_network"`
	ERTIaasIdentifier string   `hummus:"networks_configuration.networks[1].iaas_identifier,omitempty"`
	ERTCIDR           string   `json:"ert_cidr" hummus:"networks_configuration.networks[1].subnets[0].cidr,omitempty"`
	ERTReservedIPs    string   `hummus:"networks_configuration.networks[1].subnets[0].reserved_ip_ranges,omitempty"`
	ERTSubnetDNS      string   `hummus:"networks_configuration.networks[1].subnets[0].dns,omitempty"`
	ERTGateway        string   `json:"ert_gateway" hummus:"networks_configuration.networks[1].subnets[0].gateway,omitempty"`
	ERTAZs            []string `hummus:"networks_configuration.networks[1].subnets[0].availability_zones,omitempty"`

	ServicesNetworkName    string   `json:"services_subnet" hummus:"networks_configuration.networks[2].name,omitempty"`
	ServicesServiceNetwork bool     `hummus:"networks_configuration.networks[2].service_network"`
	ServicesIaasIdentifier string   `hummus:"networks_configuration.networks[2].iaas_identifier,omitempty"`
	ServicesCIDR           string   `json:"services_cidr" hummus:"networks_configuration.networks[2].subnets[0].cidr,omitempty"`
	ServicesReservedIPs    string   `hummus:"networks_configuration.networks[2].subnets[0].reserved_ip_ranges,omitempty"`
	ServicesSubnetDNS      string   `hummus:"networks_configuration.networks[2].subnets[0].dns,omitempty"`
	ServicesGateway        string   `json:"services_gateway" hummus:"networks_configuration.networks[2].subnets[0].gateway,omitempty"`
	ServicesAZs            []string `hummus:"networks_configuration.networks[2].subnets[0].availability_zones,omitempty"`

	/**Network/AZ assignment**/
	SingletonAZ     string `hummus:"network_assignment.singleton_availability_zone,omitempty"`
	AssignedNetwork string `hummus:"network_assignment.network,omitempty"`
}

func main() {
	flag.StringVar(&provider, "provider", "", "provider")
	flag.StringVar(&providerConfiguration, "provider-configuration", "", "provider-specific configuration")
	flag.StringVar(&envName, "env-name", "", "environment name")
	flag.StringVar(&awsAccessKeyID, "aws-access-key-id", "", "AWS access key ID")
	flag.StringVar(&awsSecretAccessKey, "aws-secret-access-key", "", "AWS secret access key")
	flag.Parse()

	validProviderList := []string{
		"aws",
		"azure",
		"gcp",
		"vsphere",
	}

	validProvider := false
	for _, p := range validProviderList {
		if provider == p {
			validProvider = true
		}
	}

	if !validProvider {
		log.Fatalf("invalid provider: %s", provider)
	}

	var config Config
	err := json.Unmarshal([]byte(providerConfiguration), &config)
	if err != nil {
		log.Fatalln(err)
	}

	if provider != "aws" {
		odSubnet, err := subnet.ParseSubnet(config.OpsmanCIDR)
		if err != nil {
			log.Fatalln(err)
		}

		ertSubnet, err := subnet.ParseSubnet(config.ERTCIDR)
		if err != nil {
			log.Fatalln(err)
		}

		servicesSubnet, err := subnet.ParseSubnet(config.ServicesCIDR)
		if err != nil {
			log.Fatalln(err)
		}

		if provider == "azure" {
			config.NTPServers = "us.pool.ntp.org"
			config.OpsmanReservedIPs, err = odSubnet.Range(0, 5)
			if err != nil {
				log.Fatalln(err)
			}
		} else {
			config.DefaultDeploymentTag = fmt.Sprintf("%s-vms", envName)
			config.NTPServers = "169.254.169.254"
			config.OpsmanReservedIPs, err = odSubnet.Range(0, 4)
			if err != nil {
				log.Fatalln(err)
			}
		}

		config.ERTReservedIPs, err = ertSubnet.Range(0, 4)
		if err != nil {
			log.Fatalln(err)
		}

		config.ServicesReservedIPs, err = servicesSubnet.Range(0, 3)
		if err != nil {
			log.Fatalln(err)
		}
	}

	config.ICMPChecksEnabled = false
	config.OpsmanServiceNetwork = false
	config.ERTServiceNetwork = false
	config.ServicesServiceNetwork = true
	config.OpsmanSubnetDNS = "8.8.8.8"
	config.ERTSubnetDNS = "8.8.8.8"
	config.ServicesSubnetDNS = "8.8.8.8"
	config.AssignedNetwork = config.OpsmanNetworkName

	if config.Region != "" {
		config.OpsmanIaasIdentifier = fmt.Sprintf("%s/%s/%s", config.Network, config.OpsmanNetworkName, config.Region)
		config.ERTIaasIdentifier = fmt.Sprintf("%s/%s/%s", config.Network, config.ERTNetworkName, config.Region)
		config.ServicesIaasIdentifier = fmt.Sprintf("%s/%s/%s", config.Network, config.ServicesNetworkName, config.Region)
	} else {
		config.OpsmanIaasIdentifier = fmt.Sprintf("%s/%s", config.Network, config.OpsmanNetworkName)
		config.ERTIaasIdentifier = fmt.Sprintf("%s/%s", config.Network, config.ERTNetworkName)
		config.ServicesIaasIdentifier = fmt.Sprintf("%s/%s", config.Network, config.ServicesNetworkName)
	}

	if len(config.AZs) != 0 {
		config.OpsmanAZs = config.AZs
		config.ERTAZs = config.AZs
		config.ServicesAZs = config.AZs
		config.SingletonAZ = config.AZs[0]
	}

	var finalJSON []byte
	finalJSON, err = hummus.Marshal(config)
	if err != nil {
		log.Fatalln(err)
	}

	if len(config.AZs) != 0 {
		parsedJSON, err := gabs.ParseJSON(finalJSON)
		if err != nil {
			log.Fatalln(err)
		}

		parsedJSON.Array("az_configuration", "availability_zones")

		for idx, azName := range config.AZs {
			azMap := make(map[string]string)

			azMap["name"] = azName

			switch len(config.AZs) {
			case len(config.Clusters):
				azMap["cluster"] = config.Clusters[idx]
				fallthrough
			case len(config.ResourcePools):
				azMap["resource_pool"] = config.ResourcePools[idx]
			}

			parsedJSON.ArrayAppend(azMap, "az_configuration", "availability_zones")
		}

		finalJSON = parsedJSON.Bytes()
	}

	fmt.Println(string(string(finalJSON)))
}
