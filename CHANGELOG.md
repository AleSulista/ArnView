# Changelog — ArnView

Este arquivo registra publicamente a evolução do ArnView sem expor o código-fonte das versões proprietárias.

## 0.6.0 — edição proprietária

**Status:** versão finalizada para macOS Intel (x86_64)

A linha 0.6.x marca a transição do ArnView para um modelo proprietário e amplia de forma significativa a interface de edição, o sistema de camadas e os recursos de inteligência artificial local.

### Interface e fluxo de edição

- introdução da interface **ArnGlass**;
- painel de camadas redesenhado;
- seleção de camadas diretamente na área principal de edição;
- movimentação e redimensionamento de elementos/camadas na área de trabalho;
- reorganização da ordem das camadas;
- controles inferiores mais compactos no painel de camadas;
- melhorias no controle de transparência/opacidade;
- histórico de alterações com identificação das operações realizadas;
- fluxo de desfazer/refazer preservado;
- refinamentos de usabilidade e fluidez nos ajustes de imagem;
- melhoria de fluidez do pincel de desfoque.

### Inteligência artificial e visão computacional

- remoção local de objetos com **LaMa**;
- remoção automática e inteligente de fundo;
- integração de **MODNet/Core ML** para processamento de pessoas;
- uso de **Apple Vision Foreground** para cenas e objetos compatíveis;
- detectores e auxiliares nativos para pessoas, rostos e primeiro plano;
- melhoria automática de imagem;
- redução de ruído;
- recuperação de fotos escuras;
- restauração fotográfica;
- melhoria de rostos;
- manutenção do foco em processamento local/offline sempre que a função correspondente dispõe de mecanismo integrado.

### Distribuição

- a linha 0.6.x passa a ser proprietária;
- o código-fonte da nova linha não será publicado neste repositório público;
- notas de versão, mudanças, recursos, créditos e informações de distribuição permanecem públicas;
- componentes de terceiros continuam sujeitos às respectivas licenças;
- a distribuição binária da 0.6.0 será publicada separadamente quando o pacote de distribuição estiver pronto para publicação.

## 0.4.0 — versão pública anterior

A versão 0.4.0 consolidou o ArnView como visualizador e editor de imagens para macOS Intel, reunindo:

- visualizador leve e integrado ao Finder;
- ArnView Editor;
- ajustes de imagem;
- texto sobre a imagem;
- recorte inteligente;
- remoção de objetos;
- remoção de fundo;
- redução de ruído;
- restauração e recuperação de imagens;
- melhoria de rostos;
- aumento de resolução;
- OCR;
- recursos de inteligência artificial executados localmente.

## Autoria

**ArnView — criado e desenvolvido por Alessandro Henriques Teixeira — Studio Arn.**

Copyright © 2026 Alessandro Henriques Teixeira — Studio Arn.
