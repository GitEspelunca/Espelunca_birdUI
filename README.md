# Bird UI para Glitch Soc v4.7.0-alpha.1

🐦 Adaptação completa do **Mastodon Bird UI** para **Glitch Soc**, mantendo 100% compatibilidade com a arquitetura de flavours/skins e preservando o core intacto.

## ⚡ Instalação Rápida

```bash
bash <(curl -s https://raw.githubusercontent.com/GitEspelunca/Espelunca_birdUI/main/install.sh) --path /caminho/para/glitch-soc
```

## 📋 O que será instalado

✅ **Novo Flavour Bird UI** com suporte completo para Glitch Soc  
✅ **4 Skins prontos**: Dark, Light, High Contrast, Accessible  
✅ **Compatibilidade total** com Vanilla e Glitch flavours  
✅ **Assets otimizados** e compilados  
✅ **Localizações** em EN, PT, ES, FR  
✅ **Sem modificações** ao core do Mastodon/Glitch  

## 🎯 Sabores Disponíveis

- **Glitch Edition** ✓ (mantido intacto)
- **Vanilla Mastodon** ✓ (mantido intacto)
- **Bird UI** 🆕 (novo)
  - Default (Dark)
  - Light
  - High Contrast
  - Accessible

## 📁 Estrutura do Repositório

```
Espelunca_birdUI/
├── install.sh                          # Script principal de instalação
├── scripts/
│   ├── setup-flavour.sh                # Setup do flavour Bird UI
│   ├── setup-skins.sh                  # Setup dos skins
│   ├── update-themes-yml.sh            # Atualizar config/themes.yml
│   ├── update-locales.sh               # Atualizar localizações
│   └── cleanup.sh                      # Limpeza de arquivos temporários
├── flavour/
│   └── bird-ui/                        # Conteúdo completo do flavour
│       ├── theme.yml
│       ├── names.yml
│       ├── entrypoints/
│       ├── styles/
│       ├── images/
│       └── locales/
├── skins/
│   └── bird-ui/                        # Todos os 4 skins
│       ├── default/
│       ├── light/
│       ├── contrast/
│       └── accessible/
├── entry-points/
│   ├── bird-ui-auto.scss
│   ├── bird-ui-accessible.scss
│   └── bird-ui-accessible-plus.scss
├── locales/
│   ├── en.yml
│   ├── pt.yml
│   ├── es.yml
│   └── fr.yml
└── docs/
    ├── INSTALLATION.md
    ├── ARCHITECTURE.md
    ├── CUSTOMIZATION.md
    └── TROUBLESHOOTING.md
```

## 🔧 Pré-requisitos

- Glitch Soc v4.7.0-alpha.1 ou superior
- `bash` 4.0+
- Permissões de write no diretório Glitch Soc
- Node.js + Yarn (para compilação de assets)

## 📖 Documentação

- [Guia de Instalação Detalhado](./docs/INSTALLATION.md)
- [Arquitetura do Sistema](./docs/ARCHITECTURE.md)
- [Personalização](./docs/CUSTOMIZATION.md)
- [Resolução de Problemas](./docs/TROUBLESHOOTING.md)

## 🚀 Próximas Etapas Após Instalação

1. Recompile assets:
   ```bash
   cd /caminho/para/glitch-soc
   RAILS_ENV=production bundle exec rails assets:precompile
   ```

2. Reinicie os serviços:
   ```bash
   sudo systemctl restart mastodon-web
   ```

3. Acesse `Preferences > Appearance > Theme` para selecionar Bird UI

## 📝 Licença

MIT License - Veja LICENSE para detalhes

## 🤝 Contribuições

Contribuições são bem-vindas! Abra uma issue ou pull request.

## ⚠️ Aviso

Este projeto modifica a instalação do Glitch Soc. Faça backup antes de instalar.
