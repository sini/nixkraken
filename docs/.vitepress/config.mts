import process from 'node:process'
import implicitFigures from 'markdown-it-implicit-figures'
import { defineConfig } from 'vitepress'
import { mermaidPlugin } from './plugins/vitepress-mermaid'

export default defineConfig({
  srcDir: 'src',
  title: 'NixKraken',
  base: process.env.CI ? '/nixkraken/' : '/',

  lastUpdated: true,
  metaChunk: true,

  markdown: {
    gfmAlerts: false,
    config: (md) => {
      md.use(implicitFigures, {
        figcaption: true,
        copyAttrs: '^class$'
      })
      md.use(mermaidPlugin)
    }
  },

  head: [
    [
      'link',
      { rel: 'icon', type: 'image/svg+xml', href: '/nixkraken/favicon.svg' }
    ],
    [
      'link',
      { rel: 'icon', type: 'image/png', href: '/nixkraken/favicon.png' }
    ],
    ['meta', { name: 'theme-color', content: '#42abb0' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'NixKraken' }],
    [
      'meta',
      {
        property: 'og:image',
        content: 'https://nicolas-goudry.github.io/nixkraken/nixkraken-logo.svg'
      }
    ],
    ['meta', { property: 'og:url', content: 'https://nicolas-goudry.github.io/nixkraken' }],
  ],

  themeConfig: {
    logo: { src: '/nixkraken-logo.svg', width: 24, height: 24 },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/nicolas-goudry/nixkraken' },
    ],

    search: { provider: 'local' },

    outline: { level: [2, 4] },
  },
})
