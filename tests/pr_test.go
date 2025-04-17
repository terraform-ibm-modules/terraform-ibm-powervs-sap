// Tests in this file are run in the PR pipeline
package test

import (
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const defaultExampleTerraformDir = "solutions/e2e"

var sharedInfoSvc *cloudinfo.CloudInfoService

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests

func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	// creating ssh keys
	tSsh := new(testing.T)
	rsaKeyPair, _ := ssh.GenerateRSAKeyPairE(tSsh, 4096)
	sshPublicKey := strings.TrimSuffix(rsaKeyPair.PublicKey, "\n") // removing trailing new lines
	sshPrivateKey := "<<EOF\n" + rsaKeyPair.PrivateKey + "EOF"
	if err := os.Setenv("TF_VAR_ssh_public_key", sshPublicKey); err != nil {
		tSsh.Fatalf("failed to set TF_VAR_ssh_public_key: %v", err)
	}
	if err := os.Setenv("TF_VAR_ssh_private_key", sshPrivateKey); err != nil {
		tSsh.Fatalf("failed to set TF_VAR_ssh_private_key: %v", err)
	}
	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, powervs_zone string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  defaultExampleTerraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		Region:        powervs_zone,
	})

	options.TerraformVars = map[string]interface{}{
		"powervs_zone":                options.Region,
		"prefix":                      options.Prefix,
		"powervs_resource_group_name": options.ResourceGroup,
		"external_access_ip":          "0.0.0.0/0",
		"os_image_distro":             "RHEL",
	}

	return options
}

// IMPORTANT: Keep the prefix length unchanged; it appends to an auto-generated string.

func TestRunBranchExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "b", "tok04")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunMainExample(t *testing.T) {
	t.Parallel()
	options := setupOptions(t, "m", "mad02")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
