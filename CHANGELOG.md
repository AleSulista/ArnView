# Changelog — ArnView

Este arquivo registra publicamente a evolução do ArnView sem expor o código-fonte das versões proprietárias.

## 0.7.9 — edição nativa e leve para macOS Intel

**Status:** versão finalizada para macOS Intel (x86_64)

A versão 0.7.9 consolida a migração do ArnView para uma arquitetura muito mais nativa. O foco desta linha foi reduzir dependências pesadas, diminuir o peso da distribuição e manter as ferramentas inteligentes incorporadas ao aplicativo, usando Core ML, Apple Vision e motores nativos sempre que possível.

### Leveza e arquitetura

- redução significativa da dependência de ambientes Python e grandes conjuntos de bibliotecas externas;
- maior uso dos frameworks nativos do macOS;
- modelos Core ML integrados ao aplicativo;
- motores auxiliares compilados para Intel x86_64;
- processamento local das ferramentas compatíveis;
- arquitetura preparada para manter o editor compacto sem retirar os principais recursos inteligentes.

### Inteligência artificial e visão computacional

- remoção de fundo com MODNet/Core ML e mecanismos nativos auxiliares;
- remoção de objetos com LaMa/Core ML;
- seleção inteligente baseada em Apple Vision;
- seleção interativa por clique com MobileSAM/Core ML;
- melhoria inteligente automática;
- redução de ruído;
- recuperação de fotos escuras;
- restauração fotográfica;
- melhoria de rostos;
- remoção/redução de desfoque com mecanismo nativo;
- detecção nativa de pessoas e primeiro plano;
- integração das operações inteligentes com camadas, histórico e fluxo normal de edição.

### Editor

- ferramentas inteligentes concentradas na barra lateral esquerda;
- painel direito mais limpo, dedicado a camadas e ajustes;
- sistema de camadas com seleção e manipulação direta;
- copiar, recortar e colar seleções em novas camadas;
- melhorias no trabalho com texto;
- seletor completo de cores para texto, contorno e sombra;
- expansão da sombra com visualização em tempo real;
- rotação de texto diretamente pelo mouse;
- manutenção dos ajustes contínuos, recorte, pincéis e histórico de edição.

### Visualizador

- navegação rápida entre imagens;
- miniaturas;
- zoom por scroll/trackpad;
- zoom de até 3200%;
- visualização 1:1;
- rotação e tela cheia;
- integração direta entre visualizador e editor.

### Distribuição

- versão proprietária;
- código-fonte da linha 0.7.x não publicado;
- pacote de distribuição: **ArnView-0.7.9-Intel.dmg**;
- recursos e modelos necessários às ferramentas distribuídas são incorporados ao pacote sempre que aplicável;
- componentes de terceiros permanecem sujeitos às respectivas licenças.

## 0.6.0 — edição proprietária

A linha 0.6.x marcou a transição do ArnView para o modelo proprietário e ampliou o editor, o sistema de camadas e os recursos locais de inteligência artificial. A versão introduziu a interface ArnGlass, remoção local de objetos com LaMa, MODNet/Core ML para pessoas, Apple Vision Foreground e diversos auxiliares locais.

## 0.4.0 — versão pública anterior

A versão 0.4.0 consolidou o ArnView como visualizador e editor de imagens para macOS Intel. O código público histórico permanece como registro da fase anterior do projeto e não representa o código das versões proprietárias atuais.

## Autoria

**ArnView — criado e desenvolvido por Alessandro Henriques Teixeira — Studio Arn.**

Copyright © 2026 Alessandro Henriques Teixeira — Studio Arn.
