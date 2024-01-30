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

    """
    ultramsatric -i ${msa} -o ${prefix}.scores --id ${meta.id}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": $(ultramsatric --version)
    END_VERSIONS
    """


    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.scores

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": $(ultramsatric --version)
    END_VERSIONS
    """
}
