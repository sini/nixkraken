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
  'commitGraph',
  'notifications',
  'profiles.*.commitGraph',
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
 * Prefix to remove from option names for cleaner documentation
 * @type {string}
 */
const OPTION_PREFIX = 'programs.nixkraken.'

/**
 * Main function to generate documentation from options file
 * @async
 * @function
 */
async function main() {
  try {
    // Validate command line arguments
    if (process.argv.length < 3) {
      throw new Error('Usage: node build-doc.mjs <JSON-options-file-path>')
    }

    const opts = await loadOptionsFile(process.argv[2])
    const groupedMarkdown = processOptions(opts)

    await generateDocumentationFiles(groupedMarkdown)
    await updateSummaryFile(groupedMarkdown)

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
 * @param {string} optionDef.description - Description of the option
 * @param {string} optionDef.type - Type of the option
 * @param {Object} [optionDef.default] - Default value information
 * @param {string} [optionDef.default.text] - Default value as text
 * @param {Object} [optionDef.example] - Example usage information
 * @param {string} [optionDef.example.text] - Example as text
 * @returns {string} Formatted markdown content
 */
function generateOptionMarkdown(optionName, { description, type, default: optDefault, example }) {
  const content = [
    `## ${optionName}`,
    '',
    `_${description?.trim() || 'No description provided.'}_`,
    '',
    `**Type:** ${formatType(type)}`,
    '',
    `**Default:** ${optDefault?.text || 'No default'}`,
    '',
  ]

  if (example?.text) {
    content.push(`**Example:** ${example.text}`, '')
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
  const groupPattern = new RegExp(`^(${OPTION_GROUPS.join('|')})`)
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

  for (const [groupName, content] of Object.entries(groupedMarkdown)) {
    // Handle root options separately - append to main nixkraken.md file
    if (groupName === 'root') {
      const rootFilePath = path.resolve('./src/options/nixkraken.md')

      writePromises.push(fs.appendFile(rootFilePath, '\n\n' + content.join('\n')))

      continue
    }

    const filePath = generateFilePath(groupName)
    const fullPath = path.resolve(`./src/${filePath}`)

    // Ensure directory exists
    await fs.mkdir(path.dirname(fullPath), { recursive: true })

    writePromises.push(fs.writeFile(fullPath, content.join('\n')))
  }

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
 * Updates the SUMMARY.md file with links to generated documentation
 * @async
 * @param {Object} groupedMarkdown - Grouped markdown content
 * @returns {Promise<void>}
 * @throws {Error} When marker line is not found in SUMMARY.md
 */
async function updateSummaryFile(groupedMarkdown) {
  const summaryPath = path.resolve('./src/SUMMARY.md')

  try {
    const summaryContent = await fs.readFile(summaryPath, { encoding: 'utf8' })
    const summaryLines = summaryContent.split('\n')
    const markerIndex = summaryLines.findIndex((line) => line.includes(SUMMARY_MARKER))

    if (markerIndex < 0) {
      throw new Error(`No marker '${SUMMARY_MARKER}' found in SUMMARY.md`)
    }

    const summaryEntries = generateSummaryEntries(groupedMarkdown)

    // Insert new entries at the marker position
    summaryLines.splice(markerIndex, 0, ...summaryEntries)

    await fs.writeFile(summaryPath, summaryLines.join('\n'))
  } catch (error) {
    if (error.code === 'ENOENT') {
      throw new Error(`SUMMARY.md file not found at: ${summaryPath}`)
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
