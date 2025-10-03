import fs from 'node:fs/promises'
import path from 'node:path'

/**
 * Configuration groups for organizing documentation options.
 * These groups determine how options are categorized and structured in the output.
 * @type {string[]}
 */
const OPTION_GROUPS = [
  'datetime',
  'git',
  'gpg',
  'graph',
  'notifications',
  'profiles.*.graph',
  'profiles.*.git',
  'profiles.*.gpg',
  'profiles.*.ssh',
  'profiles.*.tools',
  'profiles.*.ui',
  'profiles.*.user',
  'profiles',
  'ssh',
  'tools',
  'ui',
  'user',
]

/**
 * Marker comment used to identify where generated options should be inserted in SUMMARY.md
 * @type {string}
 */
const SUMMARY_MARKER = 'OPTS_GEN'

/**
 * Marker comment used to identify where groups should be inserted in options/nixkraken.md
 * @type {string}
 */
const GROUPS_MARKER = 'GROUPS_GEN'

/**
 * Prefix to remove from option names for cleaner documentation
 * @type {string}
 */
const OPTION_PREFIX = 'programs.nixkraken.'

/**
 * Footer text to append to all generated documentation pages
 * @type {string}
 */
const rev = process.env?.GIT_REV ?? 'dirty'
const revText = rev.includes('dirty')
  ? `*Revision: ${rev}.*`
  : `*Revision: [\`${rev}\`](https://github.com/nicolas-goudry/nixkraken/blob/${rev}).*`
const FOOTER = `
---

<center>

*This documentation was automatically generated from the NixKraken configuration options.*

*Generated on ${new Date().toISOString().replace('T', ' at ').replace(/\..*$/, '')}.*<br/>
 ${revText}

</center>
`

/**
 * Wraps a string with specified characters on both sides
 * @param {string} str - The string to wrap
 * @param {string} char - The character(s) to wrap with
 * @returns {string} The wrapped string, or original value if input is invalid
 * @example
 * wrapWith('hello', '*') // returns '*hello*'
 * wrapWith('', '*') // returns ''
 * wrapWith(null, '*') // returns null
 */
function wrapWith(str, char) {
  if (!str || typeof str !== 'string') {
    return str
  }

  if (typeof char !== 'string') {
    throw new TypeError('Character parameter must be a string')
  }

  return `${char}${str}${char}`
}

/**
 * Removes wrapping characters from the beginning and end of a string
 * Uses regex to match and extract content between the specified characters
 * @param {string} str - The string to unwrap
 * @param {string} char - The character(s) to remove from both ends
 * @returns {string} The unwrapped string, or original string if no match found
 * @example
 * unwrap('"hello"', '"') // returns 'hello'
 * unwrap('*wrapped*', '*') // returns 'wrapped'
 * unwrap('notWrapped', '"') // returns 'notWrapped'
 * unwrap(null, '"') // returns null
 */
function unwrap(str, char) {
  if (!str) {
    return str
  }

  if (typeof str !== 'string' || typeof char !== 'string') {
    return str
  }

  // Escape special regex characters to handle chars like *, +, ?, etc.
  const escapedChar = char.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const regex = new RegExp(`^${escapedChar}(.*?)${escapedChar}$`)
  const match = str.match(regex)

  return match?.[1] ?? str
}

/**
 * Main function to generate documentation from options file
 * @async
 * @function
 */
async function main() {
  try {
    // Validate command line arguments
    if (process.argv.length < 3) {
      throw new Error('Usage: node build-doc.js <JSON-options-file-path>')
    }

    const opts = await loadOptionsFile(process.argv[2])
    const groupedMarkdown = processOptions(opts)

    await generateDocumentationFiles(groupedMarkdown)
    await substituteInFile('./src/SUMMARY.md', SUMMARY_MARKER, generateSummaryEntries(groupedMarkdown).join('\n'))

    console.log('Documentation generation completed successfully!')
  } catch (error) {
    console.error('Error generating documentation:', error.message)
    process.exit(1)
  }
}

/**
 * Loads and parses the options file
 * @async
 * @param {string} filePath - Path to the options JSON file
 * @returns {Promise<Object>} Parsed options object
 * @throws {Error} When file cannot be read or parsed
 */
async function loadOptionsFile(filePath) {
  const resolvedPath = path.resolve(filePath)

  try {
    const rawContent = await fs.readFile(resolvedPath, { encoding: 'utf8' })

    return JSON.parse(rawContent)
  } catch (error) {
    if (error.code === 'ENOENT') {
      throw new Error(`Options file not found: ${resolvedPath}`)
    }

    if (error instanceof SyntaxError) {
      throw new Error(`Invalid JSON in options file: ${error.message}`)
    }

    throw error
  }
}

/**
 * Processes options and groups them by category
 * @param {Object} opts - Raw options object
 * @returns {Object} Grouped markdown content by category
 */
function processOptions(opts) {
  const groupedMarkdown = {}

  for (const [optionName, optionDefinition] of Object.entries(opts)) {
    // Skip internal module arguments
    if (optionName === '_module.args') {
      continue
    }

    const cleanOptionName = optionName.replace(OPTION_PREFIX, '')
    const markdownContent = generateOptionMarkdown(cleanOptionName, optionDefinition)
    const targetGroup = determineOptionGroup(cleanOptionName)

    addToGroup(groupedMarkdown, targetGroup, markdownContent)
  }

  return groupedMarkdown
}

/**
 * Converts an option definition to markdown documentation
 * @param {string} optionName - Name of the option (without prefix)
 * @param {Object} optionDef - Option definition object
 * @param {string} [optionDef.description] - Description of the option
 * @param {string} [optionDef.type] - Type of the option
 * @param {Object} [optionDef.default] - Default value information
 * @param {string} [optionDef.default.text] - Default value as text
 * @param {Object} [optionDef.example] - Example usage information
 * @param {string} [optionDef.example.text] - Example as text
 * @returns {string} Formatted markdown content
 */
function generateOptionMarkdown(optionName, { description, type, default: optDefault, example } = {}) {
  // Validate required parameter
  if (!optionName || typeof optionName !== 'string') {
    throw new Error('Option name is required and must be a string')
  }

  const content = [
    `### ${optionName}`,
    '',
    description || 'No description provided.',
    '',
    `**Type:** ${formatType(type)}`,
    '',
    `**Default:** ${optDefault?.text ? wrapWith(unwrap(optDefault.text, '"'), '`').replace('\\$', '$') : 'No default value'}`,
    '',
  ]

  if (example?.text) {
    content.push(...[`**Example:** ${wrapWith(unwrap(example.text, '"'), '`')}`, ''])
  }

  return content.join('\n')
}

/**
 * Formats the type string for better readability
 * @param {string} type - Raw type string
 * @returns {string} Formatted type string
 */
function formatType(type) {
  if (type === 'submodule') {
    return 'attribute set of (submodule)'
  }

  const allTypes = type
    .match(/^(.*?")/)?.[0]
    ?.split(' or ')
    ?.map((str) => str.replace('"', '')?.trim())

  if (allTypes?.includes('one of')) {
    return [
      allTypes
        .map((t) => (t === 'one of' ? 'constrained string' : t === 'string' ? 'freeform string' : t))
        .join(' or '),
      '',
      '**Valid values:**',
      ...type
        .replace(/^.*?"/, '"')
        .split(', ')
        .map((value) => `- ${wrapWith(unwrap(value, '"'), '`')}`),
    ].join('\n')
  }

  return type || 'unknown type'
}

/**
 * Determines which group an option belongs to based on its name
 * @param {string} optionName - Clean option name
 * @returns {string} Target group name
 */
function determineOptionGroup(optionName) {
  // Check for exact match first
  if (OPTION_GROUPS.includes(optionName)) {
    return optionName
  }

  // Check for pattern match
  const groupPattern = new RegExp(`^(${OPTION_GROUPS.join('|').replace('*', '\\*')})`)
  const match = optionName.match(groupPattern)

  return match ? match[0] : 'root'
}

/**
 * Adds markdown content to the appropriate group
 * @param {Object} groupedMarkdown - Object containing grouped markdown content
 * @param {string} groupName - Name of the target group
 * @param {string} content - Markdown content to add
 */
function addToGroup(groupedMarkdown, groupName, content) {
  if (!Array.isArray(groupedMarkdown[groupName])) {
    groupedMarkdown[groupName] = []
  }

  groupedMarkdown[groupName].push(content)
}

/**
 * Generates documentation files for each group
 * @async
 * @param {Object} groupedMarkdown - Grouped markdown content
 * @returns {Promise<void>}
 */
async function generateDocumentationFiles(groupedMarkdown) {
  const writePromises = []
  const groupOptions = []
  const rootFilePath = path.resolve('./src/options/nixkraken.md')

  for (const [groupName, content] of Object.entries(groupedMarkdown)) {
    const finalContent = content.join('\n') + FOOTER

    if (groupName === 'root') {
      // Handle root options separately - append to main nixkraken.md file
      writePromises.push(fs.appendFile(rootFilePath, '\n\n' + finalContent))

      continue
    }

    const filePath = generateFilePath(groupName)
    const fullPath = path.resolve(`./src/${filePath}`)

    if (!groupName.startsWith('profiles.*.')) {
      groupOptions.push(`- [${groupName}](./${groupName}.md)`)
    }

    // Ensure directory exists
    await fs.mkdir(path.dirname(fullPath), { recursive: true })

    writePromises.push(fs.writeFile(fullPath, finalContent))
  }

  writePromises.push(substituteInFile(rootFilePath, GROUPS_MARKER, groupOptions.join('\n')))

  await Promise.all(writePromises)
}

/**
 * Generates the appropriate file path for a given group
 * @param {string} groupName - Name of the group
 * @returns {string} Relative file path
 */
function generateFilePath(groupName) {
  if (groupName.startsWith('profiles.*.')) {
    const profileOption = groupName.replace('profiles.*.', '')

    return `./options/profiles/${profileOption}.md`
  }

  return `./options/${groupName}.md`
}

/**
 * Substitute given marker in file
 * @async
 * @param {String} destination - File to write to
 * @param {String} marker - Marker to replace
 * @param {String} string - String to replace marker with
 * @returns {Promise<void>}
 * @throws {Error} When marker is not found in file
 */
async function substituteInFile(destination, marker, string) {
  const resolvedPath = path.resolve(destination)

  try {
    const fileContent = await fs.readFile(resolvedPath, { encoding: 'utf8' })
    const fileLines = fileContent.split('\n')
    const markerIndex = fileLines.findIndex((line) => line.includes(marker))

    if (markerIndex < 0) {
      throw new Error(`No marker '${marker}' found in destination`)
    }

    // Insert string at the marker position
    fileLines.splice(markerIndex, 1, string)

    await fs.writeFile(resolvedPath, fileLines.join('\n'))
  } catch (error) {
    if (error.code === 'ENOENT') {
      throw new Error(`${destination} file not found at: ${resolvedPath}`)
    }

    throw error
  }
}

/**
 * Generates summary entries for the table of contents
 * @param {Object} groupedMarkdown - Grouped markdown content
 * @returns {string[]} Array of summary entry strings
 */
function generateSummaryEntries(groupedMarkdown) {
  const entries = []

  for (const groupName of Object.keys(groupedMarkdown)) {
    if (groupName === 'root') {
      continue // Root options are handled separately
    }

    const filePath = generateFilePath(groupName)

    if (groupName.startsWith('profiles.*.')) {
      const profileOption = groupName.replace('profiles.*.', '')

      entries.push(`    - [${profileOption}](${filePath})`)
    } else {
      entries.push(`  - [${groupName}](${filePath})`)
    }
  }

  return entries
}

// Execute main function
main()
