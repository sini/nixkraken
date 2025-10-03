// Array of paths where the TOC should be hidden
const hideOnPath = ['/', '/index.html', '/nixkraken/', '/nixkraken/index.html']
// Array to store the generated table of contents elements
const tocContent = []

/**
 * Populates the table of contents by finding all headers in the document
 * and creating corresponding TOC links
 */
const populateTOC = () => {
  // mdBook headers are filled with 'a.header' anchor links pointing to the matching in-page heading
  const headers = [...document.querySelectorAll('a.header')]

  // Order header elements by their document position to maintain proper hierarchy
  headers.sort((a, b) => (a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1))

  // Iterate over the list of found headers following array index order
  for (const header of headers) {
    // Get actual heading element (h1, h2, h3, ...) - the parent of the anchor
    const headingElement = header.parentElement
    // Extract the tag name (H1, H2, H3, etc.) for CSS class generation
    const headingTag = headingElement.tagName

    if (headingTag === 'H1') {
      continue
    }

    // Get header anchor link (the href attribute contains the fragment identifier)
    const headerAnchor = header.href

    // Generate TOC link content from every child node text of heading element
    // This handles cases where headings contain multiple text nodes or inline elements
    const tocLinkContent = [...headingElement.childNodes].map(({ textContent }) => textContent).join('')

    // Create DOM element to hold TOC link, populate it and add it to TOC content array
    // Uses Object.assign to set multiple properties at once
    tocContent.push(
      Object.assign(document.createElement('a'), {
        // Create CSS class based on heading level (e.g., 'toc-h1', 'toc-h2')
        className: `toc-${headingTag}`.toLowerCase(),
        // Set the link destination to the header anchor
        href: headerAnchor,
        // Set the visible text content of the TOC link
        textContent: tocLinkContent,
      }),
    )
  }
}

/**
 * Creates and injects the table of contents UI into the page
 * Only injects if there are multiple headers (more than 1)
 */
const injectTOC = () => {
  // Don't show TOC if there's only one or no headers
  if (tocContent.length <= 1) {
    return
  }

  // Find the main page container where we'll inject the TOC
  const injectionRootElement = document.querySelector('.page')

  // Create the main TOC container element
  const tocContainerElement = Object.assign(document.createElement('div'), {
    className: 'toc-container',
  })

  // Create the TOC toggle button element with accessibility attributes
  const tocBtnElement = Object.assign(document.createElement('div'), {
    className: 'toc-btn',
    label: 'Table of contents', // Accessibility label
    tabIndex: 0, // Make it keyboard focusable
  })

  // Create three line elements for the hamburger menu icon (3 horizontal lines)
  const tocBtnLineElements = Array.from({ length: 3 }, () =>
    Object.assign(document.createElement('div'), {
      className: `toc-btn__line`,
    }),
  )

  // Create the container that will hold all the TOC links
  const tocContentElement = Object.assign(document.createElement('div'), {
    className: 'toc-content',
  })

  // Function to toggle the TOC open/closed state
  const tocToggle = () => {
    tocBtnElement.classList.toggle('toc-btn__open')
  }

  // Function to close the TOC (remove open state)
  const tocClose = () => {
    tocBtnElement.classList.remove('toc-btn__open')
  }

  // Add keyboard accessibility - toggle TOC when Enter key is pressed
  tocBtnElement.addEventListener('keyup', (e) => {
    if (e.key === 'Enter' || e.code === 'Enter') {
      tocToggle()
    }
  })

  // Toggle TOC when button is clicked
  tocBtnElement.addEventListener('mouseup', tocToggle)

  // Close TOC when clicking outside of the button
  document.addEventListener('mouseup', (e) => {
    if (!tocBtnElement.contains(e.target)) {
      tocClose()
    }
  })

  // Close TOC when user scrolls the page
  document.addEventListener('scroll', tocClose)

  // Assemble the TOC structure: add all TOC links to the content container
  tocContentElement.append(...tocContent)
  // Add the hamburger lines and content to the button
  tocBtnElement.append(...tocBtnLineElements, tocContentElement)
  // Add the button to the main container
  tocContainerElement.append(tocBtnElement)
  // Insert the entire TOC at the beginning of the page
  injectionRootElement.prepend(tocContainerElement)
}

// Initialize the TOC when the DOM is fully loaded
window.addEventListener('DOMContentLoaded', () => {
  // Check if current page path is in the hide list
  const isHidden = hideOnPath.includes(window.location.pathname)
  // Get the html element to check if page is scrollable
  const htmlElement = document.querySelector('html')
  // Determine if the page content exceeds the viewport height (is scrollable)
  const isScrollable = htmlElement.scrollHeight > htmlElement.clientHeight ? true : false

  // Only show TOC if the page is scrollable and not in the hidden paths list
  if (isScrollable && !isHidden) {
    // First populate the TOC with header links
    populateTOC()
    // Then inject the TOC UI into the page
    injectTOC()
  }
})
