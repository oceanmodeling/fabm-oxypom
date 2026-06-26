# SPDX-FileCopyrightText: 2025-2026 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

rm -rf fabm.yaml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BASE_YAML="fabm_sensitive.yaml"
WORK_YAML="fabm.yaml"
MODEL_BIN="./gotm"
OUT_DIR="temp"

# Default perturbation factors for each Q10_* parameter.
FACTORS=(0.8 1.2)

if [[ ! -f "$BASE_YAML" ]]; then
	echo "Missing input file: $BASE_YAML" >&2
	exit 1
fi

if [[ ! -x "$MODEL_BIN" ]]; then
	echo "Missing executable: $MODEL_BIN" >&2
	echo "Build GOTM first (for example with test_gotm.sh)." >&2
	exit 1
fi

mkdir -p "$OUT_DIR"

mapfile -t Q10_PARAMS < <(
	grep -E '^[[:space:]]*Q10_[A-Za-z0-9_]+:' "$BASE_YAML" \
		| sed -E 's/^[[:space:]]*(Q10_[A-Za-z0-9_]+):.*/\1/'
)

if [[ ${#Q10_PARAMS[@]} -eq 0 ]]; then
	echo "No Q10_* parameters found in $BASE_YAML" >&2
	exit 1
fi

factor_tag() {
	local value="$1"
	echo "$value" | tr '.' 'p' | tr '-' 'm'
}

generate_yaml_for_param() {
	local param="$1"
	local factor="$2"

	awk -v p="$param" -v f="$factor" '
		match($0, /^([[:space:]]*)(Q10_[A-Za-z0-9_]+):[[:space:]]*([0-9.eE+-]+)(.*)$/, m) {
			if (m[2] == p) {
				new_value = m[3] * f
				printf "%s%s: %.6g%s\n", m[1], m[2], new_value, m[4]
				next
			}
		}
		{ print }
	' "$BASE_YAML" > "$WORK_YAML"
}

run_case() {
	local label="$1"

	rm -f output.nc
	"$MODEL_BIN"

	if [[ ! -f output.nc ]]; then
		echo "Model run failed: output.nc was not created for $label" >&2
		exit 1
	fi

	cp output.nc "$OUT_DIR/output_${label}.nc"
	cp "$WORK_YAML" "$OUT_DIR/fabm_${label}.yaml"
}

cp "$BASE_YAML" "$WORK_YAML"
run_case "baseline"

for param in "${Q10_PARAMS[@]}"; do
	for factor in "${FACTORS[@]}"; do
		generate_yaml_for_param "$param" "$factor"
		run_case "${param}_x$(factor_tag "$factor")"
	done
done

echo "Q10 sensitivity runs completed. Results stored in: $OUT_DIR"

Rscript plot_Q10.R