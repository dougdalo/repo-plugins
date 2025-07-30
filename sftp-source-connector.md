# Relatório de Melhorias no Fork `ftp-source-connector`

## Introdução

O fork do repositório [`ftp-source-connector`](https://github.com/dougdalo/ftp-source-connector) foi desenvolvido a partir da necessidade de tornar o conector FTP Source para Kafka Connect mais robusto, performático e resiliente, principalmente em ambientes com arquivos grandes e múltiplos processamentos simultâneos.  
A seguir, destaco as principais modificações e melhorias implementadas no código do `FtpSourceTask` em relação ao repositório original [`datastreambrasil/ftp-source-connector`](https://github.com/datastreambrasil/ftp-source-connector).

---

## Resumo das Alterações

### 1. Processamento por Lote com Controle de Estado
- **Original:** Processa todos os arquivos do diretório de uma só vez, lendo todo o conteúdo de cada arquivo em uma única chamada do método `poll()`.
- **Fork:** Implementação de **controle de estado** por arquivo. O conector lê apenas um arquivo por vez e mantém variáveis internas (`currentReader`, `currentStream`, `currentFilename`, `linesProcessed`) para continuar o processamento de onde parou no próximo ciclo do `poll()`.  
  **Benefício:** Permite processar arquivos grandes sem sobrecarregar a memória ou travar o worker do Kafka Connect.

### 2. Limite de Registros Processados por Poll
- **Original:** Não possui limitação do número de registros processados por ciclo de polling.  
- **Fork:** Introdução do parâmetro `maxRecordsPerPoll`, configurável, limitando a quantidade máxima de registros processados por ciclo.  
  **Benefício:** Garante melhor controle de uso de recursos, evita sobrecarga no cluster Kafka e melhora o balanceamento do processamento.

### 3. Gerenciamento Inteligente de Streams
- **Original:** Abre e fecha os streams/readers a cada arquivo, processando-o totalmente em uma única execução.
- **Fork:** Mantém streams/readers abertos até a leitura completa do arquivo, liberando recursos apenas quando chega ao final do arquivo (EOF).  
  **Benefício:** Reduz o overhead de abertura/fechamento repetitivo e permite retomar o processamento em arquivos grandes de forma eficiente.

### 4. Monitoramento Detalhado
- **Original:** Não há logs detalhados sobre o progresso da leitura de grandes arquivos.
- **Fork:** Inclusão de logs periódicos a cada 10.000 linhas processadas (`log.info("Processed {} lines from {}", linesProcessed, currentFilename)`), facilitando monitoramento e troubleshooting em arquivos extensos.

### 5. Arquivamento Seguro
- **Original:** Arquiva o arquivo imediatamente após a leitura total, sem considerar o risco de travamentos durante o processamento.
- **Fork:** O arquivo só é arquivado após a confirmação de leitura completa, mesmo se o processamento ocorrer em múltiplos ciclos.  
  **Benefício:** Evita perda de dados caso haja falhas no meio do processo.

### 6. Estrutura de Código mais Resiliente
- **Variáveis e métodos exclusivos:** 
  - `currentReader`, `currentStream`, `currentFilename`, `currentStagedPath`, `linesProcessed`
  - Controle de EOF e reset de estado ao término de cada arquivo
- **Parâmetro novo:** `FTP_MAX_RECORDS_PER_POLL` documentado e utilizado no fork.

---

## Vantagens e Justificativa das Alterações

- **Escalabilidade:** Torna o conector adequado para ambientes de alta volumetria, com arquivos grandes ou muitas linhas.
- **Robustez:** Diminui risco de travamento do worker e possíveis falhas de OOM (Out Of Memory).
- **Observabilidade:** Logs mais detalhados facilitam troubleshooting e acompanhamento de produção.
- **Segurança:** Evita perda de dados por garantir que só arquiva arquivos totalmente processados.

---

## Conclusão

As melhorias implementadas tornam o fork do `ftp-source-connector` muito mais robusto, seguro e preparado para uso em ambientes corporativos e de produção exigente, especialmente quando se trabalha com grandes volumes de dados via FTP ou SFTP.

**Recomendação:** Utilizar o fork melhorado como base para ambientes produtivos, ou mesmo sugerir upstream para o projeto original, agregando valor à comunidade.

---

# Diagrama de Sequência — Processamento de Arquivo em Batch
<img width="1600" height="1400" alt="diagrama-sequencia-ftp-source-connector" src="https://github.com/user-attachments/assets/244186f9-c379-4816-ab23-be2e13ca9f4b" />




> O diagrama acima ilustra o fluxo: listagem de arquivos, staging, leitura incremental em batch, envio para Kafka, arquivamento e retomada no próximo poll.

