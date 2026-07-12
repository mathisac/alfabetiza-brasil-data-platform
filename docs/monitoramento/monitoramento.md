# Monitoramento e Observabilidade

## Estratégia atual

O projeto registra evidências operacionais em arquivos versionados no repositório e exportados para o Google Drive. Essa abordagem permite auditoria e reprodução das execuções realizadas no ambiente acadêmico.

## Evidências geradas

### Pipeline end-to-end

- logs operacionais em CSV;
- logs estruturados em JSONL;
- resumo consolidado da execução;
- manifesto com metadados e status.

### Streaming simulado

- logs de processamento em CSV e JSONL;
- resumo da execução;
- manifesto com identificador único;
- arquivos de eventos aceitos e rejeitados.

### Quality gates

- resultado da validação da Bronze;
- resultado da validação da Silver;
- resultado da validação da Gold.

## Indicadores monitorados

- sucesso ou falha da execução;
- existência das tabelas;
- contagem de registros por camada;
- correspondência entre origem e destino;
- registros aceitos e rejeitados;
- tamanho aproximado dos dados;
- duração e ordem das etapas;
- aprovação ou reprovação dos quality gates.

## Tratamento de falhas

O pipeline interrompe a progressão quando um quality gate é reprovado. Na Bronze, exceções de tabela inexistente ou falta de permissão são capturadas pelo código Python. Nas camadas Silver e Gold, as consultas SQL retornam indicadores de conformidade.

## Evolução para produção

Em uma arquitetura produtiva, a observabilidade pode ser ampliada com:

- Cloud Logging;
- Cloud Monitoring;
- alertas por e-mail ou mensageria;
- métricas customizadas;
- dashboards operacionais;
- rastreamento de SLA e latência;
- orquestração com Cloud Composer, Workflows ou ferramenta equivalente.

## Rastreabilidade

Os arquivos do streaming utilizam um identificador de execução no nome. O manifesto relaciona esse identificador aos artefatos e logs produzidos, permitindo reconstruir o resultado de uma execução específica.
