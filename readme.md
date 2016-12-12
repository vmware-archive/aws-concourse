# Prepare AWS for PCF install
## Concourse pipeline

## Prerequisites

Before start kicking off the pipeline, there are a few parameters need to be set. Here is a sample parameters file [sample_file](ci/sample/pcfaws_terraform_params.yml)

* An admin account to provision AWS resources (Networks, Load Balancers ... )

  ```
  Params:
    TF_VAR_aws_access_key: XXXXXXXXXXXXXXXXXXXX
    TF_VAR_aws_secret_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ```

* Decide a domain for elastic runtime e.g pivotal-c0.com. The pipeline will use prefix apps and sys for wild card domains:

   ```
   *.apps.pivotal-c0.com
   *.sys.pivotal-c0.com
   ```

   ```
   Params:
     ERT_DOMAIN: pivotal-c0.com
   ```

* Decide a domain for ops manager e.g pivotal-c0.com. The pipeline will use prefix opsman for OPS Manager FQDN

    ```
    opsman.pivotal-c0.com
    ```

    ```
    Params:
      OPTMAN_DOMAIN: pivotal-c0.com
    ```


* Upload a Cloud Foundry wild card certificate as server certificate to AWS [Upload Certificate ](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_server-certs.html#upload-server-certificate)

  ```
  Params:
    TF_VAR_aws_cert_arn: arn:aws:acm:us-east-1:XXXX:certificate/XXXXX
  ```


* Create an AWS key pair

  ```
  Params:
    TF_VAR_aws_key_name: XXXXX
    PEM: "-----BEGIN RSA PRIVATE KEY-----\n
    -----END RSA PRIVATE KEY-----"    
  ```


* Versioned s3 bucket to store terraform state files.

  ```
    S3_ENDPOINT: https://s3.amazonaws.com
    S3_OUTPUT_BUCKET: terraform-state-c0
  ```

* Other Parameters

  * AWS RDS username and password

    Pipeline creates a rds database that users can specify username and password in advance
    ```
      TF_VAR_rds_db_username: bosh
      TF_VAR_rds_db_password: boshbosh
    ```  

  * AWS prefix for provisioned resources.

    This is used to differentiate different deploy environment by prefixing the AWS resources (E.g. ELB and S3 buckets)

    ```
      TF_VAR_environment: sandbox
    ```

  *  Ops Manager AWS AMI

    ```
    TF_VAR_opsman_ami: ami-52c5e145
    ```

  * NAT Box AMI

    Pipeline creates three nats box sits on each avaliablity zones

    ```
    TF_VAR_amis_nat: ami-303b1458
    ```

  * Regions and three availability zones

    ```
    TF_VAR_aws_region: us-east-1
    TF_VAR_az1: us-east-1a
    TF_VAR_az2: us-east-1b
    TF_VAR_az3: us-east-1d
    ```

  * Pivotal net Token to download tiles

    ```
    PIVNET_TOKEN: XXXXXX
    ```

  * An github access key to download github binary releases E.g. https://github.com/pivotal-cf/om

    ```
    GITHUB_TOKEN: XXXXXX
    ```

  * IP Prefix:

    ** Note ** : Current pipeline creates only 10.0.0.0/16 VPC CIDR. Will expose configurable CIDR later

    ```
    IP_PREFIX: 10.0
    ```

  * ERT Cert:

    ** Note ** : Since pipeline uses pre load AWS server certificate. Currently these parameters are not used.

    ```    
     ERT_SSL_CERT: generate
     ERT_SSL_KEY:
    ```

  * Syslog Host point to aggregate platform logs

    ```
     SYSLOG_HOST:
    ```

## Uploading the pipeline and running it.
### Load the pipeline to councourse

```
cd ci
fly -t local set-pipeline -p pcf-aws-prepare -c pcfaws_terraform_pipeline.yml --load-vars-from pcfaws_terraform_params.yml
fly -t local unpause-pipeline -p pcf-aws-prepare
```
