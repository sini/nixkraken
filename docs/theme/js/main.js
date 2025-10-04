window.addEventListener('DOMContentLoaded', () => {
  // Image auto-generated title
  document.querySelectorAll('p:has(img[title])').forEach((el) => {
    const title = el.querySelector('img').getAttribute('title')

    el.setAttribute('data-title', title)
  })
})
