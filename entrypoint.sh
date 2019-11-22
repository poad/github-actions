#!/bin/sh

#------------------------------------------------------------------------------------
# reference https://github.com/youyo/aws-cdk-github-actions/blob/master/entrypoint.sh
#------------------------------------------------------------------------------------

set -u

function parseInputs(){
	# Required inputs
	if [ "${INPUT_CDK_SUBCOMMAND}" == "" ]; then
		echo "Input cdk_subcommand cannot be empty"
		exit 1
	fi
}

function runCdk(){
	echo "Run cdk ${INPUT_CDK_SUBCOMMAND} ${*}"
	output=$(cdk ${INPUT_CDK_SUBCOMMAND} ${*} 2>&1)
	exitCode=${?}
	echo "${output}"

	commentStatus="Failed"
	if [ "${exitCode}" == "0" -o "${exitCode}" == "1" ]; then
		commentStatus="Success"
	fi

	if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${INPUT_ACTIONS_COMMENT}" == "true" ]; then
		commentWrapper="#### \`cdk ${INPUT_CDK_SUBCOMMAND}\` ${commentStatus}
<details><summary>Show Output</summary>
\`\`\`
${output}
\`\`\`
</details>
*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Working Directory: \`${INPUT_WORKING_DIR}\`*"

		payload=$(echo "${commentWrapper}" | jq -R --slurp '{body: .}')
		commentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)

		echo "${payload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${commentsURL}" > /dev/null
	fi
}

function main(){
	cd ${GITHUB_WORKSPACE}/${INPUT_WORKING_DIR} && \
	runCdk
}

main
