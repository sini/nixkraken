// Map mdBook theme names to their corresponding Mermaid theme schemes
const mdBookThemeToMermaid = {
  ayu: 'dark',
  coal: 'dark',
  light: 'default',
  navy: 'dark',
  rust: 'default',
}

/**
 * Observes class attribute changes on a DOM node and triggers a callback when changes occur
 * @param {HTMLElement} node - The DOM node to observe
 * @param {Function} callback - Function to call when class changes are detected
 * @returns {MutationObserver} The mutation observer instance
 */
const onClassChange = (node, callback) => {
  // Track the last known class string to detect actual changes
  let lastClassString = node.classList.toString()

  const mutationObserver = new MutationObserver((mutationList) => {
    // Check if any mutation affected the class attribute
    const classChanged = mutationList.some((item) => item.attributeName === 'class')

    if (classChanged) {
      const classString = node.classList.toString()

      // Only trigger callback if the class string actually changed
      if (classString !== lastClassString) {
        lastClassString = classString

        callback()
      }
    }
  })

  // Start observing attribute changes on the node
  mutationObserver.observe(node, { attributes: true })

  return mutationObserver
}

/**
 * Gets the current mdBook theme by checking which theme class is present on the HTML element
 * @returns {string|undefined} The current mdBook theme name
 */
const getMDBookTheme = () => {
  const htmlClasses = document.documentElement.classList

  return Object.keys(mdBookThemeToMermaid).find((theme) => htmlClasses.contains(theme))
}

/**
 * Checks if two mdBook themes map to different Mermaid color schemes
 * @param {string} currentTheme - The current mdBook theme
 * @param {string} nextTheme - The next mdBook theme
 * @returns {boolean} True if the themes have different Mermaid schemes
 */
const nextThemeHasDifferentScheme = (currentTheme, nextTheme) =>
  mdBookThemeToMermaid[currentTheme] !== mdBookThemeToMermaid[nextTheme]

/**
 * Initializes Mermaid with the appropriate theme based on the current mdBook theme
 * @param {string} mdBookTheme - The current mdBook theme name
 */
const setMermaidTheme = (mdBookTheme) => {
  mermaid.initialize({ theme: mdBookThemeToMermaid?.[mdBookTheme] ?? 'default' })
}

/**
 * Finds all Mermaid code blocks, processes them, and stores their source for later retrieval
 */
const processMermaidDiagrams = async () => {
  // Find all pre elements containing Mermaid code blocks
  const diagrams = document.querySelectorAll('.mermaid')

  for (const diagram of diagrams) {
    // Set the data-content attribute to a base64 representation of the diagram
    diagram.setAttribute('data-content', btoa(diagram.textContent))
  }
}

/**
 * Resets all Mermaid diagrams to their original source code state
 * This is necessary before re-rendering with a new theme
 */
const resetMermaidDiagrams = async () => {
  const diagrams = document.querySelectorAll('.mermaid')

  diagrams.forEach((diagram) => {
    // Restore the original diagram source from the data-content attribute
    diagram.textContent = atob(diagram.getAttribute('data-content'))
    // Remove the processed flag so Mermaid will re-render it
    diagram.removeAttribute('data-processed')
  })
}

// Initialize everything when the DOM is ready
window.addEventListener('DOMContentLoaded', () => {
  // Get the initial mdBook theme
  let mdBookTheme = getMDBookTheme()

  // Process all Mermaid diagrams on the page
  processMermaidDiagrams()
  // Set the initial Mermaid theme
  setMermaidTheme(mdBookTheme)

  // Watch for theme changes on the HTML element
  onClassChange(document.documentElement, () => {
    const nextMDBookTheme = getMDBookTheme()

    // Only re-render diagrams if the color scheme actually changed (dark vs light)
    if (nextThemeHasDifferentScheme(mdBookTheme, nextMDBookTheme)) {
      resetMermaidDiagrams().then(() => {
        // Apply the new theme
        setMermaidTheme(nextMDBookTheme)
        // Re-render all Mermaid diagrams
        mermaid.run()
      })
    }

    // Update the current theme tracker
    mdBookTheme = nextMDBookTheme
  })
})
