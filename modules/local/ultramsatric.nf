process ULTRAMSATRIC {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(msa)//, path(ref_msa)

    output:
    tuple val(meta), path("*.scores"), emit: scores
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    // compatibility with TCOFFEE/ALNCOMPARE
    def metric_name = 'umsa'
    def header = meta.keySet().join(",")
    def values = meta.values().join(",")

    """
    ultramsatric -o scores.csv --id ${meta.id} --no-header -m ufrob

    # compatibility with TCOFFEE/ALNCOMPARE
    # Add metadata info to output file
    echo "${header},${metric_name}" > "${prefix}.scores"

    # Add values
    scores=\$(awk '{sub(/[[:space:]]+\$/, "")} 1' scores.csv | tr -s '[:blank:]' ',')
    echo "${values},\$scores" >> "${prefix}.scores"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ultramsatric: \$(ultramsatric --version)
    END_VERSIONS
    """


    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.scores

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ultramsatric: \$(ultramsatric --version)
    END_VERSIONS
    """
}
