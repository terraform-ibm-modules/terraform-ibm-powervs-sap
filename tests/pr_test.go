// Tests in this file are run in the PR pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const defaultExampleTerraformDir = "examples/basic"

// Ignore below create, update, destroy due to https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4046
var ignoreDestroys = []string{
	"module.sap_systems.module.sap_netweaver_instance[0].ibm_pi_volume_attach.instance_volumes_attach[0]",
	"module.sap_systems.module.sap_netweaver_instance[0].ibm_pi_volume_attach.instance_volumes_attach[1]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[0]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[1]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[2]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[3]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[4]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[5]",
	"module.sap_systems.module.sap_netweaver_instance[0].ibm_pi_instance.sap_instance",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_instance.sap_instance",
}

var IgnoreAdds = []string{
	"module.sap_systems.module.sap_netweaver_instance[0].ibm_pi_volume_attach.instance_volumes_attach[0]",
	"module.sap_systems.module.sap_netweaver_instance[0].ibm_pi_volume_attach.instance_volumes_attach[1]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[0]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[1]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[2]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[3]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[4]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume_attach.instance_volumes_attach[5]",
	"module.sap_systems.module.sap_netweaver_instance[0].ibm_pi_instance.sap_instance",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_instance.sap_instance",
}

var ignoreUpdates = []string{
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume.create_volume[0]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume.create_volume[1]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume.create_volume[2]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume.create_volume[3]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume.create_volume[4]",
	"module.sap_systems.module.sap_hana_instance.ibm_pi_volume.create_volume[5]",
	"module.sap_systems.module.create_sap_network.ibm_pi_network.additional_network",
	"module.sap_systems.module.sap_netweaver_instance[0].ibm_pi_volume.create_volume[0]",
	"module.sap_systems.module.sap_netweaver_instance[0].ibm_pi_volume.create_volume[1]",
}

func setupOptions(t *testing.T, prefix string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  defaultExampleTerraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
	})

	options.TerraformVars = map[string]interface{}{
		"prefix":         options.Prefix,
		"resource_group": options.ResourceGroup,
	}

	return options
}

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "power-sap")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	// TODO: Remove this line after the first merge to master branch is complete to enable upgrade test
	t.Skip("Skipping upgrade test until initial code is in master branch")

	options := setupOptions(t, "power-sap-upg")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
