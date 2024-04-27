package conftest.terraform.tflint

import rego.v1

msg_terraform_naming_convention(rule_name) := sprintf(
	"`%v` rule must be defined with true in .tflint.hcl",
	[rule_name],
)

# METADATA
# description: |
#  .tflint.hclでterraform_naming_conventionルールが有効になっていなければいけない
# authors:
# - name: fittecs
# custom:
#  severity: MEDIUM
deny_terraform_naming_convention contains decision if {
	data.conftest.file.name == ".tflint.hcl"
	not input.rule.terraform_naming_convention.enabled
	decision := {
		"severity": rego.metadata.rule().custom.severity,
		"msg": msg_terraform_naming_convention("terraform_naming_convention"),
	}
}

# METADATA
# description: |
#  .tflint.hclでterraform_comment_syntaxルールが有効になっていなければいけない
# authors:
# - name: fittecs
# custom:
#  severity: MEDIUM
deny_terraform_comment_syntax contains decision if {
	data.conftest.file.name == ".tflint.hcl"
	not input.rule.terraform_comment_syntax.enabled
	decision := {
		"severity": rego.metadata.rule().custom.severity,
		"msg": msg_terraform_naming_convention("terraform_comment_syntax"),
	}
}
