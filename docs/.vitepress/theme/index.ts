import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import BackToTopButton from '../plugins/vitepress-back-to-top-button'
import VitePressMermaid from '../plugins/vitepress-mermaid/index.vue'
import '@fortawesome/fontawesome-free/css/all.css'
import './styles.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    BackToTopButton(app, {
      progressColor: 'var(--vp-c-brand-1)',
    })
    app.component('vitepress-mermaid', VitePressMermaid)
  },
} satisfies Theme
